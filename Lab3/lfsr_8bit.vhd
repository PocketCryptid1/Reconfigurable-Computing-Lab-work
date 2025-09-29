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
		result: out std_logic_vector(7 downto 0)
	);
end entity lfsr_8bit;

architecture behavioral of lfsr_8bit is
	-- [SIGNALS] --
	signal feedback : std_logic;
	signal lfsr_reg : std_logic_vector(7 downto 0) := x"69"; -- arbitrary, known value
	
begin
	-- [PROCESSES] --
	process (clk, rst_l)
	begin		
		-- active low async reset
		if rst_l = '0' then
			lfsr_reg <= seed;
			
		elsif rising_edge(clk) and enabled = '0' then
			-- shift the bits to the right
			feedback <= lfsr_reg(7) xor lfsr_reg(5) xor lfsr_reg(4) xor lfsr_reg(3);
			lfsr_reg <= feedback & lfsr_reg(7 downto 1);
		end if;
	end process;
	
	-- [SIGNAL CONNECTIONS] --
	result <= lfsr_reg;

end architecture behavioral;