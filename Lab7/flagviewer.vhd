library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flagviewer is
	port (
		-- [INPUTS ] --
		clk 		: in std_logic;								-- 50MHz clock input
		key		: in std_logic_vector(1 downto 0);		-- button inputs 
		
		-- [OUTPUTS] --
		vga_r 	: out std_logic_vector(3 downto 0);		-- r pixel value
		vga_b		: out std_logic_vector(3 downto 0);		-- b pixel value
		vga_g		: out std_logic_vector(3 downto 0);		-- g pixel value
		vga_hs	: out std_logic;								-- HS controller
		vga_vs	: out std_logic								-- VS controller
	);
end entity flagviewer;

architecture behavioral of flagviewer is
	-- [COMPONENTS] --
	component debounce
		port(
			clk 	: in std_logic;	-- The clock that drives the state machine
			d_in 	: in std_logic;	-- The value to debounce
			d_out : out std_logic	-- The debounced value
		);
	end component debounce;
	
	component vga
		port (
			clk 		: in std_logic;								-- clock input
			pixel		: in std_logic_vector(11 downto 0);			-- the async pixel value
			vga_r 	: out std_logic_vector(3 downto 0);				-- r pixel value
			vga_b		: out std_logic_vector(3 downto 0);			-- b pixel value
			vga_g		: out std_logic_vector(3 downto 0);			-- g pixel value
			vga_hs	: out std_logic;								-- HS controller
			vga_vs	: out std_logic								-- VS controller
		);
	end component vga;
	
	-- [SIGNALS] --
	-- Signals that retain the current coordinate of the current pixel
	signal x	: integer range 0 to 480;
	signal y	: integer range 0 to 640;
	
	-- Signal that retains information of the current pixel color (RGB)
	signal pixel : std_logic_vector(11 downto 0) := (others => '0');
	
	-- Signals that control state machine behavior that shows the correct, current flag
	signal crnt_flag	: std_logic_vector(3 downto 0) := "0000";
	signal next_flag	: std_logic_vector(3 downto 0) := "0000";
	
	-- Signals that represent the debounced button values
	signal next_db : std_logic;
	signal rst_db  : std_logic;
	
	-- [CONSTANTS] --
	constant FRANCE 	: std_logic_vector(3 downto 0) := "0000";		-- the first, default flag
	constant ITALY 	: std_logic_vector(3 downto 0) := "0001";
	constant IRELAND 	: std_logic_vector(3 downto 0) := "0010";
	constant BELGIUM 	: std_logic_vector(3 downto 0) := "0011";
	constant MALI 		: std_logic_vector(3 downto 0) := "0100";
	constant CHAD 		: std_logic_vector(3 downto 0) := "0101";
	constant NIGERIA 	: std_logic_vector(3 downto 0) := "0110";
	constant IVORY 	: std_logic_vector(3 downto 0) := "0111";
	constant POLAND 	: std_logic_vector(3 downto 0) := "1000";
	constant GERMANY 	: std_logic_vector(3 downto 0) := "1001";
	constant AUSTRIA 	: std_logic_vector(3 downto 0) := "1010";
	constant CONGO 	: std_logic_vector(3 downto 0) := "1011";
	constant HOLD 		: std_logic_vector(3 downto 0) := "1100";
	
begin
	-- [INTSTANCES] --
	next_db_impl : debounce port map (clk => clk, d_in => not key(0), d_out => next_db);
	rst_db_impl  : debounce port map (clk => clk, d_in => not key(1), d_out => rst_db);
	
	vga_impl : vga port map(
		clk => clk, 
		pixel => to_stdlogicvector(x"a0f"), 
		vga_r => vga_r, 
		vga_g => vga_g,
		vga_b => vga_b,
		vga_hs => vga_hs,
		vga_vs => vga_vs
	);
	
	-- [PROCESSES] --
	-- Next Flag Machine
	
	-- Current Flag Machine
	
end architecture behavioral;