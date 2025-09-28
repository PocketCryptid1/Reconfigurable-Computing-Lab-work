library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng is 
	port(
		-- [Inputs] --
		ADC_CLK_10: in std_logic;
		KEY: in std_logic_vector(1 downto 0);
		
		-- [Outputs] --
		HEX0: out std_logic_vector(7 downto 0);
		HEX1: out std_logic_vector(7 downto 0);
		HEX2: out std_logic_vector(7 downto 0);
		HEX3: out std_logic_vector(7 downto 0);
		HEX4: out std_logic_vector(7 downto 0);
		HEX5: out std_logic_vector(7 downto 0)
	);	
end entity rng;

architecture behavioral of rng is
begin
	-- [COMPONENTS] --
	component seg
		port(
			point: in std_logic;
			count: in unsigned(3 downto 0);
			display: out std_logic_vector(7 downto 0)
		);
	end component seg;
	
	-- TODO: Add the lfsr_8bit component
	
	-- [SIGNALS] --
	
	-- [PROCESSES] --

end architecture behavioral;
