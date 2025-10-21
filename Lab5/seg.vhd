library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg is
	port(
		point: in std_logic;
		count: in unsigned(3 downto 0);
		output: out std_logic_vector(7 downto 0)
	);
end entity seg;

architecture behavioral of seg is
	signal segvalue : std_logic_vector(6 downto 0);
	
begin
	process (count) begin
		case(count) is
			when to_unsigned(0, 4) => 	segvalue <= "1000000"; -- 0
			when to_unsigned(1, 4) => 	segvalue <= "1111001"; -- 1
			when to_unsigned(2, 4) => 	segvalue <= "0100100"; -- 2
			when to_unsigned(3, 4) => 	segvalue <= "0110000"; -- 3
			when to_unsigned(4, 4) => 	segvalue <= "0011001"; -- 4
			when to_unsigned(5, 4) => 	segvalue <= "0010010"; -- 5
			when to_unsigned(6, 4) => 	segvalue <= "0000010"; -- 6
			when to_unsigned(7, 4) => 	segvalue <= "1111000"; -- 7
			when to_unsigned(8, 4) => 	segvalue <= "0000000"; -- 8
			when to_unsigned(9, 4) => 	segvalue <= "0011000"; -- 9
			when to_unsigned(10, 4) => segvalue <= "0001000"; -- A
			when to_unsigned(11, 4) => segvalue <= "0000011"; -- B
			when to_unsigned(12, 4) => segvalue <= "1000110"; -- C
			when to_unsigned(13, 4) => segvalue <= "0100001"; -- D
			when to_unsigned(14, 4) => segvalue <= "0000110"; -- E
			when to_unsigned(15, 4) => segvalue <= "0001110"; -- F
			when others => segvalue <= "1000000"; -- 0
		end case;
		
		output <= (not point) & segvalue;
	end process;
end architecture behavioral;
