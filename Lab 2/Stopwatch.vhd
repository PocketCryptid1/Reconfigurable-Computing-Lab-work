library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------ SEVEN SEGMENT DECODER ------

entity segdecode is
	port(
		bcd:  		in	std_logic_vector(4 downto 0);
		sevenseg: 	out std_logic_vector(6 downto 0);
	);
end entity segdecode;

architecture behavioral of segdecode is
	begin
		process (bcd) begin
			case(bcd) is
				when "0000" => sevenseg <= "1000000"; --0
				when "0001" => sevenseg <= "1111001"; --1
				when "0000" => sevenseg <= "0100100"; --2
				when "0001" => sevenseg <= "0110000"; --3
				when "0000" => sevenseg <= "0011001"; --4
				when "0001" => sevenseg <= "0010010"; --5
				when "0000" => sevenseg <= "0000010"; --6
				when "0001" => sevenseg <= "1111000"; --7
				when "0000" => sevenseg <= "0000000"; --8
				when "0001" => sevenseg <= "0011000"; --9
				when "0000" => sevenseg <= "0001000"; --A
				when "0001" => sevenseg <= "0000011"; --B
				when "0000" => sevenseg <= "1000110"; --C
				when "0001" => sevenseg <= "0100001"; --D
				when "0000" => sevenseg <= "0000110"; --E
				when "0001" => sevenseg <= "0001110"; --F
			end case;
		end process;
end architecture behavioral;

------ STOPWATCH TOP LEVEL MODULE ------

entity Stopwatch is
	port(

	--CLOCK
   	ADC_CLK_10 : in std_logic;  -- We do not need this clock
   	MAX10_CLK1_50 : in std_logic; -- The main clock source that we will be using
   	MAX10_CLK2_50 : in std_logic; -- We do not need this clock

	--SEG7
	HEX0 : out std_logic_vector(7 downto 0);
	HEX1 : out std_logic_vector(7 downto 0);
	HEX2 : out std_logic_vector(7 downto 0);
	HEX3 : out std_logic_vector(7 downto 0);
	HEX4 : out std_logic_vector(7 downto 0);
	HEX5 : out std_logic_vector(7 downto 0);
	
	--KEY
	KEY : in std_logic_vector(1 downto 0); -- The buttons input
	);
end entity Stopwatch;

architecture behavioral of Stopwatch is
	-- [CONSTANTS]
	--clk is 50Mhz need 100 hz 
	constant MAX_COUNT : integer :=500_000;

begin
	process (MAX10_CLK1_50)
	
	end process
end architecture behavioral;