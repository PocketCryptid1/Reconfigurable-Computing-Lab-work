library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
	port (
		-- [INPUTS] --
		clk 		: in std_logic;								-- clock input
		pixel		: in std_logic_vector(11 downto 0);		-- the async pixel value
		
		-- [OUTPUTS]--
		vga_r 	: out std_logic_vector(3 downto 0);		-- r pixel value
		vga_b		: out std_logic_vector(3 downto 0);		-- b pixel value
		vga_g		: out std_logic_vector(3 downto 0);		-- g pixel value
		vga_hs	: out std_logic;								-- HS controller
		vga_vs	: out std_logic;								-- VS controller
	);
end entity vga;

architecture behavioral of vga is
	-- [SIGNALS] --
	
	-- [CONSTANTS] --
	
begin
	-- [DIRECT CONNECTIONS] --
	
	-- [PROCESSES] --

end architecture behavioral;