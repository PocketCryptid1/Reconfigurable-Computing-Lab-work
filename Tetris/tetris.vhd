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
	
	-- [CONSTANTS] --
	constant BG: std_logic_vector(11 downto 0) := "000000000000";
	
	-- [SIGNALS] --
	-- The game board
	signal game: game_board;
	
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
	
	-- Components for the graphic stack
	-- Controls the drawing of the animation of the block falling
	component animations is
		port(
			clk: in std_logic;
			px_x: in integer range 0 to 639;
			px_y: in integer range 0 to 479;
			piece: in piece;
			drop_x: in integer range 0 to 9;
			drop_y: in integer range 0 to 16;
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
	
	animations_impl : animations port map (
		clk => clk,
		px_x => px_x,
		px_y => px_y,
		piece => PIECE_A,
		drop_x => 4,
		drop_y => 15,
		px_en => animations_en,
		px_out => animations_px
	);
	
	blocks_impl : blocks port map (
		clk => clk,
		px_x => px_x,
		px_y => px_y,
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
		px_en => score_en,
		px_out => score_px
	);
	
	-- [DIRECT BEHAVIOR] --
	
	-- [PROCESSES] --
	
	process (clk) begin
		if rising_edge(clk) then
			
			-- The graphical stack:
			if animations_en = '1' then
				px_out <= animations_px;
			elsif blocks_en = '1' then
				px_out <= blocks_px;
			elsif board_en = '1' then
				px_out <= board_px;
			elsif score_en = '1' then
				px_out <= score_px;
			else
				px_out <= BG;
			end if;
		end if;
	end process;
end architecture behavioral;


























