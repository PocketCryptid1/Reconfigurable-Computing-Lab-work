library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg is
	port(
		point: in std_logic;
		count: in unsigned(3 downto 0);
		display: out std_logic_vector(7 downto 0)
	);
end entity seg;

architecture behavioral of seg is
	signal segvalue : std_logic_vector(6 downto 0);
	
	begin
		process (bcd) begin
			case(bcd) is
				when 0 => segvalue <= "1000000"; --0
				when 1 => segvalue <= "1111001"; --1
				when 2 => segvalue <= "0100100"; --2
				when 3 => segvalue <= "0110000"; --3
				when 4 => segvalue <= "0011001"; --4
				when 5 => segvalue <= "0010010"; --5
				when 6 => segvalue <= "0000010"; --6
				when 7 => segvalue <= "1111000"; --7
				when 8 => segvalue <= "0000000"; --8
				when 9 => segvalue <= "0011000"; --9
				when 10 => segvalue <= "0001000"; --A
				when 11 => segvalue <= "0000011"; --B
				when 12 => segvalue <= "1000110"; --C
				when 13 => segvalue <= "0100001"; --D
				when 14 => segvalue <= "0000110"; --E
				when 15 => segvalue <= "0001110"; --F
				when others => segvalue <= "0000000"; --8
			end case;
			
			display <= (not point) & segvalue;
		end process;
end architecture behavioral;
