library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg is
	port(
		point: in std_logic;
		count: in std_logic_vector(3 downto 0);
		display: out std_logic_vector(7 downto 0)
	);
end entity seg;

architecture behavioral of seg is
	signal segvalue : std_logic_vector(6 downto 0);
	
begin
	process (count) begin
		case(count) is
			when "0000" => segvalue <= "1000000"; -- 0
			when "0001" => segvalue <= "1111001"; -- 1
			when "0010" => segvalue <= "0100100"; -- 2
			when "0011" => segvalue <= "0110000"; -- 3
			when "0100" => segvalue <= "0011001"; -- 4
			when "0101" => segvalue <= "0010010"; -- 5
			when "0110" => segvalue <= "0000010"; -- 6
			when "0111" => segvalue <= "1111000"; -- 7
			when "1000" => segvalue <= "0000000"; -- 8
			when "1001" => segvalue <= "0011000"; -- 9
			when "1010" => segvalue <= "0001000"; -- A
			when "1011" => segvalue <= "0000011"; -- B
			when "1100" => segvalue <= "1000110"; -- C
			when "1101" => segvalue <= "0100001"; -- D
			when "1110" => segvalue <= "0000110"; -- E
			when "1111" => segvalue <= "0001110"; -- F
			when others => segvalue <= "1000000"; -- 0
		end case;
		
		display <= (not point) & segvalue;
	end process;
end architecture behavioral;
