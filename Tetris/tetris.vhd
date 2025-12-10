library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.main.all;

entity tetris is 
	port(
		-- [INPUTS] --
		clk: in std_logic;
		key: in std_logic_vector(1 downto 0);  -- Key(0) = reset, Key(1) = start
		
		-- [INOUTS] --
		arduino_io: inout std_logic_vector(15 downto 0);  -- Pin 0 = left, Pin 1 = right, Pin 2 = buzzer out
		
		-- [OUTPUTS] --
		vga_r: out std_logic_vector(3 downto 0);
		vga_g: out std_logic_vector(3 downto 0);
		vga_b: out std_logic_vector(3 downto 0);
		vga_hs: out std_logic;
		vga_vs: out std_logic
	);
end entity tetris;

architecture behavioral of tetris is
	-- [TYPES] --
	type game_state is (RST, SPAWN, MOVE_CHECK, FALL, CHECK, CLEAR, APPLY_GRAVITY, UPDATE, LOSE, IDLE);
	
	-- [CONSTANTS] --
	constant BG: std_logic_vector(11 downto 0) := "000000000000";
	constant MAX_FALL_COUNT: integer := 1666667;  -- ~30 frames per second (50MHz / 30fps)
	constant BOARD_TOP: integer := 16;            -- Top edge of play area
	constant BOARD_BOTTOM: integer := 464;        -- Bottom edge (16 + 14*32)
	constant BOARD_LEFT: integer := 176;          -- Left edge of play area
	constant BOARD_RIGHT: integer := 464;         -- Right edge (176 + 288)
	constant PIECE_SIZE: integer := 32;           -- Cube size in pixels
	constant MAX_ROWS: integer := 14;             -- 448 pixels / 32
	constant MAX_COLS: integer := 9;              -- 288 pixels / 32
	constant LOSS_THRESHOLD: integer := 2;        -- Loss if piece tops within 2 cube heights of top
	
	-- [SIGNALS] --
	-- The game board (15 rows x 9 columns based on 448/32 and 288/32)
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
	
	signal game_started: std_logic := '0';
	signal game_over: std_logic := '0';
	
	signal active_piece: piece := PIECE_A;
	signal current_row : integer range 0 to 15 := 0;
	signal current_col : integer range 0 to 9 := 4; -- Start in middle
	signal desired_col : integer range 0 to 9 := 4;
	
	signal fall_counter: integer range 0 to 100000000 := 0;
	signal move_made: std_logic := '0';
	
	-- Animation signals
	signal drop_x: integer range 0 to 639 := 304;
	signal drop_y: integer range 0 to 479 := 16;
	signal do_drop_anim: std_logic := '0';

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
	signal clear_rows: std_logic_vector(14 downto 0) := (others => '0'); -- Rows to clear
	signal cubes_to_clear: integer range 0 to 135 := 0;
	
	-- RNG signals
	signal rng_counter: std_logic_vector(7 downto 0) := (others => '0');
	
	-- Sound signals
	signal buzzer_out: std_logic := '0';
	signal sound_active: std_logic := '0';
	signal sound_type: integer range 0 to 3 := 0;  -- 0=move, 1=land, 2=clear, 3=gameover
	signal sound_counter: integer range 0 to 100000000 := 0;
	signal sound_freq_counter: integer range 0 to 100000 := 0;
	
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
	
	component animations
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
	
	component blocks
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			active_board: in game_board;
			px_en: out std_logic;
			px_out: out std_logic_vector(11 downto 0)
		);	
	end component blocks;
	
	component board
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			px_en: out std_logic;
			px_out: out std_logic_vector(11 downto 0)
		);	
	end component board;
	
	component score
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
	
	-- Buzzer output to Arduino pin 2
	arduino_io(2) <= buzzer_out;
	
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
			game_over <= '0';
		elsif rising_edge(clk) then
			crnt_state <= next_state;
			if next_state = LOSE then
				game_over <= '1';
			elsif crnt_state = RST then
				game_over <= '0';
			end if;
		end if;
	end process;
	
	-- Next state logic (combinational)
	process (crnt_state, game_started, current_row, current_col, active_board, clear_rows) 
	begin
		next_state <= crnt_state; -- Default: stay in current state
		
		case crnt_state is
			when RST => 
				next_state <= SPAWN;
				
			when SPAWN =>
				next_state <= MOVE_CHECK;
				
			when MOVE_CHECK =>
				next_state <= FALL;
				
			when FALL => 
				next_state <= CHECK;
				
			when CHECK => 
				-- Check if cube can fall further
				if current_row >= MAX_ROWS then
					-- Hit bottom
					next_state <= CLEAR;
				elsif active_board(current_row + 1, current_col) /= NONE then
					-- Hit another cube
					next_state <= CLEAR;
				elsif current_row <= LOSS_THRESHOLD then
					-- Loss condition met
					next_state <= LOSE;
				else
					-- Can fall further
					next_state <= MOVE_CHECK;
				end if;
				
			when CLEAR => 
				-- Check if any rows have matches
				if clear_rows /= (clear_rows'range => '0') then
					next_state <= UPDATE;
				elsif game_started = '1' then
					next_state <= SPAWN;
				else
					next_state <= IDLE;
				end if;
				
			when UPDATE => 
				next_state <= APPLY_GRAVITY;
				
			when APPLY_GRAVITY =>
				next_state <= CLEAR;
				
			when LOSE => 
				if game_started = '0' then 
					next_state <= LOSE;
				else
					next_state <= LOSE;
				end if;
				
			when IDLE =>
				if game_started = '1' then
					next_state <= SPAWN;
				else
					next_state <= IDLE;
				end if;
				
			when others => 
				next_state <= RST;
		end case;
	end process;
	
	-- State outputs and actions (registered)
	process (clk, rst_db) begin
		if rst_db = '1' then
			-- Reset all signals
			active_board <= (others => (others => NONE));
			active_score <= (others => '0');
			do_drop_anim <= '0';
			game_started <= '0';
			current_row <= 0;
			current_col <= 4;
			desired_col <= 4;
			fall_counter <= 0;
			clear_rows <= (others => '0');
			cubes_to_clear <= 0;
			rng_counter <= (others => '0');
			sound_active <= '0';
			
		elsif rising_edge(clk) then
			-- Store previous button states for edge detection
			btn_prev <= btn_db;
			left_prev <= left_db;
			right_prev <= right_db;
			
			-- Update RNG counter (free-running LFSR)
			rng_counter <= std_logic_vector(unsigned(rng_counter) + 1);
			
			-- Handle sound output
			if sound_active = '1' then
				sound_counter <= sound_counter + 1;
				if sound_counter >= sound_freq_counter then
					buzzer_out <= not buzzer_out;
					sound_counter <= 0;
				end if;
				if sound_counter >= 1000000 then  -- Duration ~20ms at 50MHz
					sound_active <= '0';
					buzzer_out <= '0';
				end if;
			end if;
			
			-- Detect start button press (rising edge)
			if btn_db = '1' and btn_prev = '0' then
				game_started <= '1';
			end if;
			
			case crnt_state is
				when RST => 
					active_board <= (others => (others => NONE));
					active_score <= (others => '0');
					do_drop_anim <= '0';
					game_started <= '0';
					current_row <= 0;
					current_col <= 4;
					desired_col <= 4;
					fall_counter <= 0;
					clear_rows <= (others => '0');
					cubes_to_clear <= 0;
					
			when SPAWN =>
				-- Spawn new piece at top center
				current_row <= 0;
				current_col <= 4;
				desired_col <= 4;
				do_drop_anim <= '0';
				fall_counter <= 0;
				
				-- Select random piece based on counter
				case (to_integer(unsigned(rng_counter(1 downto 0)))) is
					when 0 => active_piece <= PIECE_A; -- Red
					when 1 => active_piece <= PIECE_B; -- Blue
					when 2 => active_piece <= PIECE_C; -- Green
					when 3 => active_piece <= PIECE_D; -- Yellow
					when others => active_piece <= PIECE_A;
				end case;
				
				-- Place piece on board at top - check if space is available
				-- If not available, we'll detect loss condition in CHECK state
				active_board(0, 4) <= active_piece;
				
			when MOVE_CHECK =>
				-- Check for left/right button presses
				if left_db = '1' and left_prev = '0' then
					-- Move left
					if current_col > 0 and active_board(current_row, current_col - 1) = NONE then
						desired_col <= current_col - 1;
						move_made <= '1';
					end if;
				end if;
				
				if right_db = '1' and right_prev = '0' then
					-- Move right
					if current_col < MAX_COLS and active_board(current_row, current_col + 1) = NONE then
						desired_col <= current_col + 1;
						move_made <= '1';
					end if;
				end if;
				
				-- Apply movement if desired column differs from current
				if desired_col /= current_col then
					-- Clear old position
					active_board(current_row, current_col) <= NONE;
					-- Move to new position
					active_board(current_row, desired_col) <= active_piece;
					current_col <= desired_col;
					
					-- Play movement sound
					sound_active <= '1';
					sound_type <= 0;
					sound_freq_counter <= 50000;  -- ~500Hz
					sound_counter <= 0;
				end if;
				move_made <= '0';
					
				when FALL => 
					-- Increment fall counter
					fall_counter <= fall_counter + 1;
					
					if fall_counter >= MAX_FALL_COUNT then
						-- Time to fall
						if current_row < MAX_ROWS then
							-- Clear old position and move piece down
							active_board(current_row, current_col) <= NONE;
							active_board(current_row + 1, current_col) <= active_piece;
							current_row <= current_row + 1;
						end if;
						fall_counter <= 0;
					end if;
					
				when CHECK => 
					-- No actions, just state transition
					
					-- Check if piece landed (hit something)
					if current_row >= MAX_ROWS or 
					   active_board(current_row + 1, current_col) /= NONE then
						-- Play land sound
						sound_active <= '1';
						sound_type <= 1;
						sound_freq_counter <= 100000;  -- ~250Hz
						sound_counter <= 0;
					end if;
					
				when CLEAR => 
					-- Detect and mark rows for clearing
					clear_rows <= (others => '0');
					cubes_to_clear <= 0;
					
					-- Check for horizontal matches (3+ in a row)
					for row in 0 to MAX_ROWS loop
						for col in 0 to MAX_COLS - 2 loop
							if active_board(row, col) /= NONE and
							   active_board(row, col) = active_board(row, col + 1) and
							   active_board(row, col) = active_board(row, col + 2) then
								clear_rows(row) <= '1';
							end if;
						end loop;
					end loop;
					
					-- Check for vertical matches (3+ in a column)
					for col in 0 to MAX_COLS loop
						for row in 0 to MAX_ROWS - 2 loop
							if active_board(row, col) /= NONE and
							   active_board(row, col) = active_board(row + 1, col) and
							   active_board(row, col) = active_board(row + 2, col) then
								clear_rows(row) <= '1';
								clear_rows(row + 1) <= '1';
								clear_rows(row + 2) <= '1';
							end if;
						end loop;
					end loop;
					
				when UPDATE => 
					-- Clear marked rows and count cubes
					cubes_to_clear <= 0;
					for row in 0 to MAX_ROWS loop
						if clear_rows(row) = '1' then
							for col in 0 to MAX_COLS loop
								if active_board(row, col) /= NONE then
									cubes_to_clear <= cubes_to_clear + 1;
								end if;
								active_board(row, col) <= NONE;
							end loop;
						end if;
					end loop;
					
					-- Update score
					if cubes_to_clear > 0 then
						active_score <= std_logic_vector(unsigned(active_score) + to_unsigned(cubes_to_clear, 24));
						-- Play clear sound
						sound_active <= '1';
						sound_type <= 2;
						sound_freq_counter <= 75000;  -- ~333Hz
						sound_counter <= 0;
					end if;
					
				when APPLY_GRAVITY =>
					-- Apply gravity - move cubes down to fill gaps
					for row in MAX_ROWS - 1 downto 0 loop
						for col in 0 to MAX_COLS loop
							if active_board(row, col) /= NONE and 
							   active_board(row + 1, col) = NONE and 
							   row < MAX_ROWS then
								active_board(row + 1, col) <= active_board(row, col);
								active_board(row, col) <= NONE;
							end if;
						end loop;
					end loop;
					clear_rows <= (others => '0');
					
				when LOSE => 
					do_drop_anim <= '0';
					-- Play game over sound
					if crnt_state /= LOSE then
						sound_active <= '1';
						sound_type <= 3;
						sound_freq_counter <= 200000;  -- ~125Hz
						sound_counter <= 0;
					end if;
					
				when IDLE =>
					-- Waiting for game start
					
				when others => 
					do_drop_anim <= '0';
			end case;
		end if;
	end process;
	
end architecture behavioral;
