library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.main.all;

entity tetris is 
	port(
		-- [INPUTS] --
		clk: in std_logic;
		key: in std_logic_vector(1 downto 0);
		
		gsensor_int: in std_logic_vector(2 downto 1);
		
		-- [INOUTS] --
		gsensor_sdi: inout std_logic;
		gsensor_sdo: inout std_logic;
		
		arduino_io: inout std_logic_vector(15 downto 0);
		arduino_reset_n: inout std_logic;
		
		-- [OUTPUTS] --
		vga_r: out std_logic_vector(3 downto 0);
		vga_g: out std_logic_vector(3 downto 0);
		vga_b: out std_logic_vector(3 downto 0);
		vga_hs: out std_logic;
		vga_vs: out std_logic;
		
		gsensor_cs_n: out std_logic;
		gsensor_sclk: out std_logic
	);
end entity tetris;

architecture behavioral of tetris is
	-- [TYPES] --
	type game_state is (RST, RNG, ANIM, ANIM_WAIT, FALL, CHECK, CLEAR, UPDATE, LOSE);
	
	-- [CONSTANTS] --
	constant BG: std_logic_vector(11 downto 0) := "000000000000";
	constant MAX_FALL_COUNT: integer 0 to 100e6 := 50e6 / 1;
	
	-- [SIGNALS] --
	-- The game board
	signal active_board: game_board := (others => (others => NONE));
	
	signal active_score: std_logic_vector(23 downto 0);
	
	-- Input signals
	signal rst_db: std_logic;
	signal btn_db: std_logic;
	signal left_db: std_logic;
	signal right_db: std_logic;
	
	-- State signals
	signal crnt_state: game_state := RST;
	signal next_state: game_state := RST;
	
	signal rng_ready: std_logic;
	signal fall_anim_done: std_logic;
	signal falling: std_logic;
	signal place_top_row: std_logic;
	signal clearing: std_logic;

	signal active_piece: piece := PIECE_A;
	signal current_row : integer range 0 to 15 := 0;
	signal current_col : integer range 0 to 9 := 0;
	
	signal anim_rate_count: integer range 0 to 500000;
	signal anim_px_count: integer range 0 to 32;
	signal do_drop_anim: std_logic;
	signal drop_x: integer range 0 to 639;
	signal drop_y: integer range 0 to 479;

	-- Signals that retain the current coordinate of the current pixel
	signal px_x	: integer range 0 to 639;
	signal px_y	: integer range 0 to 479;
	
	-- Enabled signals
	signal animations_en: std_logic;
	signal blocks_en: std_logic;
	signal board_en: std_logic;
	signal score_en: std_logic;
	
	-- Pixel signals
	signal animations_px: std_logic_vector(11 downto 0) := (others => '-');
	signal blocks_px: std_logic_vector(11 downto 0) := (others => '-');
	signal board_px: std_logic_vector(11 downto 0) := (others => '-');
	signal score_px: std_logic_vector(11 downto 0) := (others => '-');
	signal px_out : std_logic_vector(11 downto 0) := BG;

	--counter signals
	signal counter: integer := 0;
	signal buzzer_counter: integer := 0;
	
	-- [COMPONENTS] --
	-- Component for the VGA module
	component vga
		port (
			clk: in std_logic; -- clock input
			pixel: in std_logic_vector(11 downto 0); -- the async pixel value
			vga_r: out std_logic_vector(3 downto 0); -- r pixel value
			vga_b: out std_logic_vector(3 downto 0);-- b pixel value
			vga_g: out std_logic_vector(3 downto 0); -- g pixel value
			vga_hs: out std_logic; -- HS controller
			vga_vs: out std_logic; -- VS controller
			x_coord: out integer range 0 to 639; -- current x coordinate (0-639)
			y_coord: out integer range 0 to 479	-- current y coordinate (0-479)
		);
	end component vga;
	
	component debounce
		port(
			clk 	: in std_logic;	-- The clock that drives the state machine
			d_in 	: in std_logic;	-- The value to debounce
			d_out : out std_logic	-- The debounced value
		);
	end component debounce;
	
	-- Components for the graphic stack
	-- Controls the drawing of the animation of the block falling
	component animations is
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			do_drop: in std_logic;
			piece: in piece;
			drop_x: in integer range 0 to 639;
			drop_y: in integer range 0 to 479;
			px_en: out std_logic;
			px_out: out std_logic_vector(11 downto 0)
		);	
	end component animations;
	
	-- Controls the drawing of placed blocks
	component blocks is
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			active_board: in game_board;
			px_en: out std_logic;
			px_out: out std_logic_vector(11 downto 0)
		);	
	end component blocks;
	
	-- Controls the drawing of the board
	component board is
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			px_en: out std_logic;
			px_out: out std_logic_vector(11 downto 0)
		);	
	end component board;
	
	-- Controls the drawing of the score
	component score is
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			score_in: in std_logic_vector(23 downto 0);
			px_en: out std_logic;
			px_out: out std_logic_vector(11 downto 0)
		);	
	end component score;

begin
	-- [INSTANCES] --
	vga_impl : vga port map(
		clk => clk, 
		pixel => px_out, 
		vga_r => vga_r, 
		vga_g => vga_g,
		vga_b => vga_b,
		vga_hs => vga_hs,
		vga_vs => vga_vs,
		x_coord => px_x,
		y_coord => px_y
	);
	
	rst_db_impl : debounce port map (clk => clk, d_in => not key(0), d_out => rst_db);
	btn_db_impl  : debounce port map (clk => clk, d_in => not key(1), d_out => btn_db);
	left_db_impl : debounce port map (clk => clk, d_in => not arduino_io(0), d_out => left_db);
	right_db_impl  : debounce port map (clk => clk, d_in => not arduino_io(1), d_out => right_db);
	
	animations_impl : animations port map (
		clk => clk,
		px_x => px_x,
		px_y => px_y,
		do_drop => do_drop_anim,
		piece => active_piece,
		drop_x => drop_x,
		drop_y => drop_y,
		px_en => animations_en,
		px_out => animations_px
	);
	
	blocks_impl : blocks port map (
		clk => clk,
		px_x => px_x,
		px_y => px_y,
		active_board => active_board,
		px_en => blocks_en,
		px_out => blocks_px
	);
	
	board_impl : board port map (
		clk => clk,
		px_x => px_x,
		px_y => px_y,
		px_en => board_en,
		px_out => board_px
	);
	
	score_impl : score port map (
		clk => clk,
		px_x => px_x,
		px_y => px_y,
		score_in => active_score,
		px_en => score_en,
		px_out => score_px
	);
	
	-- [DIRECT BEHAVIOR] --
	
	-- [PROCESSES] --
	
	process (clk) begin
		if rising_edge(clk) then
			-- The graphical stack:
			if board_en = '1' then
				px_out <= board_px;
			elsif score_en = '1' then
				px_out <= score_px;
			elsif blocks_en = '1' then
				px_out <= blocks_px;
			elsif animations_en = '1' then
				px_out <= animations_px;
			else
				px_out <= BG;
			end if;
			
			-- reading game state
			process (clk, next_state) begin
				if rising_edge(clk) then
					crnt_state <= next_state;
					case (next_state) is
						when RST => 
							active_board <= (others => (others => NONE));
							do_drop_anim <= '0';
							
						when RNG => 
							do_drop_anim <= '0';
							active_piece <= DROP_A;
							drop_x = 304;
							drop_y = 16;
							
						when ANIM => 
							do_drop_anim <= '1';
							drop_x <= current_col * 32 + 176;
							drop_y <= current_row * 32 - 16 + anim_px_count;
							anim_rate_count <= 0;
							
						when ANIM_WAIT =>
							do_drop_anim <= '1';
							anim_rate_count <= anim_rate_count + 1;
							
						when FALL => 
							do_drop_anim <= '0';
							active_board(current_row, current_col) = NONE;
							active_board(current_row + 1, current_col) = active_piece;
							
						when CHECK => 
							do_drop_anim <= '0';
							
						when CLEAR => 
							do_drop_anim <= '0';
							
						when UPDATE => 
							do_drop_anim <= '0';
							
						when LOSE => 
							do_drop_anim <= '0';
							
						when others => 
							active_board <= active_board;
							do_drop_anim <= '0';
							
					end case;
				end if;
			
			end process;
			
			-- writing game state
			process (crnt_state, ready, anim_rate_count, anim_px_count, falling, 
						place_top_row, clearing, active_board, current_row, current_col) 
			begin
				case (crnt_state) is
						when RST => 
							next_state <= RNG;
						
						when RNG => 
							if ready = '1' then next_state <= ANIM;
							else next_state <= RNG; end if;
							
						when ANIM => 
							if anim_px_count >= 32 then next_state <= FALL;
							else next_state <= ANIM_WAIT; end if;
							
						when ANIM_WAIT =>
							if anim_rate_count >= MAX_FALL_COUNT then
								next_state <= ANIM;
								anim_px_count <= anim_px_count + 1;
							else next_state <= ANIM_WAIT; end if;
							
						when FALL => 
							next_state <= CHECK;
							
						when CHECK => 
							if active_board(current_row + 1, current_col) = NONE then next_state <= ANIM;
							else
								active_board(current_row + 1, current_col) <= 
							end if;
							elsif clearing = '1' then next_state <= CLEAR;
							elsif place_top_row = '1' then next_state <= LOSE;
							else next_state <= RNG; end if;
						
						when CLEAR => 
							next_state <= UPDATE;
							
						when UPDATE => 
							next_state <= CHECK;
							
						when LOSE => 
							if rst_db = '1' then next_state <= RST;
							else next_state <= LOSE; end if;
							
						when others => next_state <= RST;
					end case;
			end process;
			
		end if;
	end process;
end architecture behavioral;


























