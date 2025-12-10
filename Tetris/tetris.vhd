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
	type game_state is (RST, RNG, SPAWN, MOVE_CHECK, ANIM, ANIM_WAIT, FALL, CHECK, CLEAR, UPDATE, LOSE);
	
	-- [CONSTANTS] --
	constant BG: std_logic_vector(11 downto 0) := "000000000000";
	constant MAX_FALL_COUNT: integer := 50000000 / 30; -- Adjust speed here
	constant MAX_ANIM_COUNT: integer := 500000;
	
	-- [SIGNALS] --
	-- The game board (14 rows x 9 columns based on 448/32 and 288/32)
	signal active_board: game_board := (others => (others => NONE));
	
	signal active_score: std_logic_vector(23 downto 0) := (others => '0');
	
	-- Input signals
	signal rst_db: std_logic;
	signal btn_db: std_logic;
	signal btn_prev: std_logic := '0';
	signal left_db: std_logic;
	signal left_prev: std_logic := '0';
	signal right_db: std_logic;
	signal right_prev: std_logic := '0';
	
	-- State signals
	signal crnt_state: game_state := RST;
	signal next_state: game_state := RST;
	
	signal rng_ready: std_logic := '0';
	signal game_started: std_logic := '0';
	
	signal active_piece: piece := PIECE_A;
	signal current_row : integer range 0 to 15 := 0;
	signal current_col : integer range 0 to 9 := 4; -- Start in middle
	signal desired_col : integer range 0 to 9 := 4;
	
	signal anim_rate_count: integer range 0 to 100000000 := 0;
	signal anim_px_count: integer range 0 to 32 := 0;
	signal fall_counter: integer range 0 to 100000000 := 0;
	
	signal do_drop_anim: std_logic := '0';
	signal drop_x: integer range 0 to 639 := 304;
	signal drop_y: integer range 0 to 479 := 16;

	-- Signals that retain the current coordinate of the current pixel
	signal px_x	: integer range 0 to 639;
	signal px_y	: integer range 0 to 479;
	
	-- Enabled signals
	signal animations_en: std_logic;
	signal blocks_en: std_logic;
	signal board_en: std_logic;
	signal score_en: std_logic;
	
	-- Pixel signals
	signal animations_px: std_logic_vector(11 downto 0) := (others => '0');
	signal blocks_px: std_logic_vector(11 downto 0) := (others => '0');
	signal board_px: std_logic_vector(11 downto 0) := (others => '0');
	signal score_px: std_logic_vector(11 downto 0) := (others => '0');
	signal px_out : std_logic_vector(11 downto 0) := BG;

	-- Clearing signals
	signal clear_mask: std_logic_vector(13 downto 0) := (others => '0'); -- Rows to clear
	signal clearing_active: std_logic := '0';
	signal cubes_cleared: integer range 0 to 255 := 0;
	
	-- [COMPONENTS] --
	component vga
		port (
			clk: in std_logic;
			pixel: in std_logic_vector(11 downto 0);
			vga_r: out std_logic_vector(3 downto 0);
			vga_b: out std_logic_vector(3 downto 0);
			vga_g: out std_logic_vector(3 downto 0);
			vga_hs: out std_logic;
			vga_vs: out std_logic;
			x_coord: out integer range 0 to 639;
			y_coord: out integer range 0 to 479
		);
	end component vga;
	
	component debounce
		port(
			clk 	: in std_logic;
			d_in 	: in std_logic;
			d_out : out std_logic
		);
	end component debounce;
	
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
	
	component board is
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			px_en: out std_logic;
			px_out: out std_logic_vector(11 downto 0)
		);	
	end component board;
	
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
	
	-- [PROCESSES] --
	
	-- Graphics stack priority multiplexer
	process (clk) begin
		if rising_edge(clk) then
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
		end if;
	end process;
	
	-- State register process
	process (clk, rst_db) begin
		if rst_db = '1' then
			crnt_state <= RST;
		elsif rising_edge(clk) then
			crnt_state <= next_state;
		end if;
	end process;
	
	-- Next state logic (combinational)
	process (crnt_state, game_started, rng_ready, anim_px_count, anim_rate_count, 
	         fall_counter, active_board, current_row, current_col, clearing_active, rst_db)
	begin
		next_state <= crnt_state; -- Default: stay in current state
		
		case crnt_state is
			when RST => 
				next_state <= RNG;
				
			when RNG => 
				if game_started = '1' and rng_ready = '1' then 
					next_state <= SPAWN;
				else 
					next_state <= RNG;
				end if;
				
			when SPAWN =>
				next_state <= MOVE_CHECK;
				
			when MOVE_CHECK =>
				next_state <= ANIM;
				
			when ANIM => 
				if anim_px_count >= 32 then 
					next_state <= FALL;
				else 
					next_state <= ANIM_WAIT;
				end if;
				
			when ANIM_WAIT =>
				if anim_rate_count >= MAX_ANIM_COUNT then
					next_state <= ANIM;
				else 
					next_state <= ANIM_WAIT;
				end if;
				
			when FALL => 
				next_state <= CHECK;
				
			when CHECK => 
				-- Check if cube can fall further
				if current_row >= 13 then
					-- Hit bottom
					next_state <= CLEAR;
				elsif active_board(current_row + 1, current_col) /= NONE then
					-- Hit another cube
					next_state <= CLEAR;
				else
					-- Can fall further, check for loss condition first
					if current_row <= 1 then
						next_state <= LOSE;
					else
						next_state <= MOVE_CHECK;
					end if;
				end if;
				
			when CLEAR => 
				if clearing_active = '1' then
					next_state <= UPDATE;
				else
					next_state <= RNG;
				end if;
				
			when UPDATE => 
				next_state <= CLEAR;
				
			when LOSE => 
				if rst_db = '1' then 
					next_state <= RST;
				else 
					next_state <= LOSE;
				end if;
				
			when others => 
				next_state <= RST;
		end case;
	end process;
	
	-- State outputs and actions (registered)
	process (clk) begin
		if rising_edge(clk) then
			-- Store previous button states for edge detection
			btn_prev <= btn_db;
			left_prev <= left_db;
			right_prev <= right_db;
			
			case crnt_state is
				when RST => 
					active_board <= (others => (others => NONE));
					active_score <= (others => '0');
					do_drop_anim <= '0';
					game_started <= '0';
					current_row <= 0;
					current_col <= 4;
					desired_col <= 4;
					anim_px_count <= 0;
					anim_rate_count <= 0;
					fall_counter <= 0;
					clearing_active <= '0';
					cubes_cleared <= 0;
					
				when RNG => 
					do_drop_anim <= '0';
					current_row <= 0;
					current_col <= 4;
					desired_col <= 4;
					anim_px_count <= 0;
					fall_counter <= 0;
					
					-- Detect start button press (rising edge)
					if btn_db = '1' and btn_prev = '0' then
						game_started <= '1';
					end if;
					
					-- Simple RNG simulation (you should replace with actual RNG)
					rng_ready <= '1';
					-- Rotate through colors based on counter or use LFSR
					case (to_integer(unsigned(active_score(1 downto 0)))) is
						when 0 => active_piece <= PIECE_A; -- Red
						when 1 => active_piece <= PIECE_B; -- Blue
						when 2 => active_piece <= PIECE_C; -- Green
						when 3 => active_piece <= PIECE_D; -- Yellow
						when others => active_piece <= PIECE_A;
					end case;
					
				when SPAWN =>
					-- Place piece at top center of board
					active_board(0, current_col) <= active_piece;
					drop_x <= current_col * 32 + 176;
					drop_y <= 16;
					
				when MOVE_CHECK =>
					-- Check for horizontal movement input
					if left_db = '1' and left_prev = '0' then
						if current_col > 0 then
							desired_col <= current_col - 1;
						end if;
					elsif right_db = '1' and right_prev = '0' then
						if current_col < 8 then
							desired_col <= current_col + 1;
						end if;
					end if;
					
					-- Update column if different
					if desired_col /= current_col then
						active_board(current_row, current_col) <= NONE;
						active_board(current_row, desired_col) <= active_piece;
						current_col <= desired_col;
					end if;
					
				when ANIM => 
					do_drop_anim <= '1';
					drop_x <= current_col * 32 + 176;
					drop_y <= current_row * 32 + 16 + anim_px_count;
					anim_rate_count <= 0;
					anim_px_count <= anim_px_count + 1;
					
				when ANIM_WAIT =>
					do_drop_anim <= '1';
					anim_rate_count <= anim_rate_count + 1;
					
				when FALL => 
					do_drop_anim <= '0';
					-- Move piece down one row
					active_board(current_row, current_col) <= NONE;
					active_board(current_row + 1, current_col) <= active_piece;
					current_row <= current_row + 1;
					anim_px_count <= 0;
					
				when CHECK => 
					do_drop_anim <= '0';
					-- Just checking, no actions here
					
				when CLEAR => 
					do_drop_anim <= '0';
					clearing_active <= '0';
					cubes_cleared <= 0;
					
					-- Check for sequences of 3 or more
					-- Horizontal check
					for row in 0 to 13 loop
						for col in 0 to 6 loop -- 0-6 allows checking col, col+1, col+2
							if active_board(row, col) /= NONE and
							   active_board(row, col) = active_board(row, col+1) and
							   active_board(row, col) = active_board(row, col+2) then
								clearing_active <= '1';
								clear_mask(row) <= '1';
								cubes_cleared <= cubes_cleared + 3;
							end if;
						end loop;
					end loop;
					
					-- Vertical check
					for col in 0 to 8 loop
						for row in 0 to 11 loop -- 0-11 allows checking row, row+1, row+2
							if active_board(row, col) /= NONE and
							   active_board(row, col) = active_board(row+1, col) and
							   active_board(row, col) = active_board(row+2, col) then
								clearing_active <= '1';
								-- Mark all three rows for clearing
								clear_mask(row) <= '1';
								clear_mask(row+1) <= '1';
								clear_mask(row+2) <= '1';
								cubes_cleared <= cubes_cleared + 3;
							end if;
						end loop;
					end loop;
					
				when UPDATE => 
					do_drop_anim <= '0';
					
					-- Clear marked cubes and update score
					for row in 0 to 13 loop
						if clear_mask(row) = '1' then
							for col in 0 to 8 loop
								active_board(row, col) <= NONE;
							end loop;
						end if;
					end loop;
					
					-- Update score (BCD addition would be better for display)
					active_score <= std_logic_vector(unsigned(active_score) + to_unsigned(cubes_cleared, 24));
					
					-- Apply gravity - move cubes down to fill gaps
					for row in 12 downto 0 loop -- Start from bottom-1 going up
						for col in 0 to 8 loop
							if active_board(row, col) /= NONE and active_board(row+1, col) = NONE then
								active_board(row+1, col) <= active_board(row, col);
								active_board(row, col) <= NONE;
							end if;
						end loop;
					end loop;
					
					clear_mask <= (others => '0');
					clearing_active <= '0';
					
				when LOSE => 
					do_drop_anim <= '0';
					-- Game over, wait for reset
					
				when others => 
					do_drop_anim <= '0';
			end case;
		end if;
	end process;
	
end architecture behavioral;