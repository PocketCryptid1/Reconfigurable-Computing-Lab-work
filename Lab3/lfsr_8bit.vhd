library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr_8bit is
	port(
		-- [INPUTS] --
		clk : in std_logic;
		rst_l : in std_logic;
		enabled : in std_logic;
		seed : in std_logic_vector(7 downto 0);
		
		-- [OUTPUTS] --
		result: out std_logic_vector(7 downto 0);
	);
end entity lfsr_8bit;

architecture behavioral of lfsr_8bit is
begin
	-- [SIGNALS] --
	signal feedback : std_logic;
	signal lsfr_reg : std_logic_vector(7 downto 0) := x"69"; -- arbitrary, known value
	
	-- [PROCESSES] --
	process (clk, rst_l)
	begin		
		-- active low async reset
		if rst_l = '0' then
			lsfr_reg <= seed;
			
		elsif rising_edge(clk) and enabled = '1' then
			-- shift the bits to the right
			lfsr_reg <= feedback & lsfr_reg(7 downto 1);
		end if;
	end process;
	
	-- [SIGNAL CONNECTIONS] --
	feedback <= lfsr_reg(7) xor lfsr_reg(5) xor lfsr_reg(4) xor lfsr_reg(3);
	result <= lfsr_reg;

end architecture behavioral;