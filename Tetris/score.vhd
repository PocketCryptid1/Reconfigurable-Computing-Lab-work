library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity score is
	port(
		-- [INPUTS] --
		clk: in std_logic;
		px_x: in integer range 0 to 639;
		px_y: in integer range 0 to 479;
		score: in std_logic_vector(23 downto 0);
		
		-- [OUTPUTS] --
		px_en: out std_logic;
		px_out: out std_logic_vector(11 downto 0)
	);	
end entity score;

architecture behavioral of score is
	-- [TYPES] --
	
	-- [CONSTANTS] --
	
	-- [SIGNALS] --

begin
	-- [DIRECT BEHAVIOR] --
	px_en <= '0';
	px_out <= (others => '0');
	
	-- [PROCESSES] --
end architecture behavioral;











