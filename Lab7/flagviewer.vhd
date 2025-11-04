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
			vga_vs	: out std_logic;								-- VS controller
			x_coord 	: out integer range 0 to 639;				-- current x coordinate (0-639)
			y_coord	: out integer range 0 to 479				-- current y coordinate (0-479)
		);
	end component vga;
	
	-- [SIGNALS] --
	-- Signals that retain the current coordinate of the current pixel
	signal x	: integer range 0 to 639;
	signal y	: integer range 0 to 479;
	
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
	
begin
	-- [INTSTANCES] --
	next_db_impl : debounce port map (clk => clk, d_in => not key(0), d_out => next_db);
	rst_db_impl  : debounce port map (clk => clk, d_in => not key(1), d_out => rst_db);
	
	vga_impl : vga port map(
		clk => clk, 
		pixel => pixel, 
		vga_r => vga_r, 
		vga_g => vga_g,
		vga_b => vga_b,
		vga_hs => vga_hs,
		vga_vs => vga_vs,
		x_coord => x,
		y_coord => y
	);
	
	-- [PROCESSES] --
	-- Next Flag Machine
	process (clk) begin
		if rising_edge(clk) then
			crnt_flag <= next_flag;
			
			case (next_flag) is
				when FRANCE =>
					if x < 213 then pixel <= to_stdlogicvector(x"00f");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"fff");
					else pixel <= to_stdlogicvector(x"f00"); end if;
					
				when ITALY =>
					if x < 213 then pixel <= to_stdlogicvector(x"0f0");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"fff");
					else pixel <= to_stdlogicvector(x"f00"); end if;
					
				when IRELAND =>
					if x < 213 then pixel <= to_stdlogicvector(x"0f0");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"fff");
					else pixel <= to_stdlogicvector(x"fa0"); end if;
					
				when BELGIUM =>
					if x < 213 then pixel <= to_stdlogicvector(x"000");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"ff0");
					else pixel <= to_stdlogicvector(x"f00"); end if;
					
				when MALI =>
					if x < 213 then pixel <= to_stdlogicvector(x"0f0");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"ff0");
					else pixel <= to_stdlogicvector(x"f00"); end if;
				
				when CHAD =>
					if x < 213 then pixel <= to_stdlogicvector(x"005");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"ff0");
					else pixel <= to_stdlogicvector(x"f00"); end if;
					
				when NIGERIA =>
					if x < 213 then pixel <= to_stdlogicvector(x"0f0");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"fff");
					else pixel <= to_stdlogicvector(x"0f0"); end if;
				
				when IVORY =>
					if x < 213 then pixel <= to_stdlogicvector(x"fa0");
					elsif x >= 213 and x < 426 then pixel <= to_stdlogicvector(x"fff");
					else pixel <= to_stdlogicvector(x"0f0"); end if;
				
				when POLAND =>
					if y < 240 then pixel <= to_stdlogicvector(x"fff");
					else pixel <= to_stdlogicvector(x"f00"); end if;
				
				when GERMANY =>
					if y < 160 then pixel <= to_stdlogicvector(x"000");
					elsif y >= 160 and y < 320 then pixel <= to_stdlogicvector(x"f00");
					else pixel <= to_stdlogicvector(x"ff0"); end if;
				
				when AUSTRIA =>
					if y < 160 then pixel <= to_stdlogicvector(x"f00");
					elsif y >= 160 and y < 320 then pixel <= to_stdlogicvector(x"fff");
					else pixel <= to_stdlogicvector(x"f00"); end if;
				
				when CONGO =>
					if y < 480 - x then pixel <= to_stdlogicvector(x"0f0");
					elsif y > 640 - x then pixel <= to_stdlogicvector(x"f00");
					else pixel <= to_stdlogicvector(x"ff0"); end if;
			
				when others => pixel <= to_stdlogicvector(x"aa0");
			end case;
		end if;
	end process;
	
	-- Current Flag Machine
	process (crnt_flag, next_db, rst_db) begin
		if next_db = '1' then
			if crnt_flag = CONGO then next_flag <= FRANCE;
			else next_flag <= std_logic_vector(unsigned(crnt_flag) + to_unsigned(1, 4)); end if;
		elsif rst_db = '1' then next_flag <= FRANCE;
		else next_flag <= crnt_flag; end if;
	end process;
end architecture behavioral;