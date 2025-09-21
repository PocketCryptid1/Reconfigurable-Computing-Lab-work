library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stopwatch is
	port(

	//////////// CLOCK //////////
   ADC_CLK_10 : in std_logic;  -- We do not need this clock
   MAX10_CLK1_50 : in std_logic; -- The main clock source that we will be using
   MAX10_CLK2_50 : in std_logic; -- We do not need this clock

	//////////// SEG7 //////////
	HEX0 : out std_logic_vector(7 downto 0);
	HEX1 : out std_logic_vector(7 downto 0);
	HEX2 : out std_logic_vector(7 downto 0);
	HEX3 : out std_logic_vector(7 downto 0);
	HEX4 : out std_logic_vector(7 downto 0);
	HEX5 : out std_logic_vector(7 downto 0);
	
	//////////// KEY //////////
	KEY : in std_logic_vector(1 downto 0); -- The buttons input
	);
end entity Stopwatch;

architecture behavioral of Stopwatch is

end architecture behavioral