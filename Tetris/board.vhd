library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity board is
	port(
		-- [INPUTS] --
		clk: in std_logic;
		px_x: in integer range 0 to 639;
		px_y: in integer range 0 to 479;
		
		-- [OUTPUTS] --
		px_en: out std_logic;
		px_out: out std_logic_vector(11 downto 0)
	);	
end entity board;

architecture behavioral of board is
	-- [TYPES] --
	
	-- [CONSTANTS] --
	constant COLOR: std_logic_vector(11 downto 0) := (others => '1');
	
	-- [SIGNALS] --

begin
	-- [DIRECT BEHAVIOR] --
	
	-- [PROCESSES] --
	process (clk) begin
		if rising_edge(clk) then
			if 
				((px_x = 176 or px_x = 464) and px_y >= 16 and px_y <= 464) or -- Left/right edges
				(px_y = 464 and px_x >= 176 and px_x <= 464) -- Bottom edge
			then
				px_en <= '1';
				px_out <= COLOR;
				
			else
				px_en <= '0';
				px_out <= (others => '0');
			end if;
			
		end if;
	end process;
end architecture behavioral;











