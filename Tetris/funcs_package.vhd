library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.main.all;

package funcs is 
	function piece_color(p: piece) return std_logic_vector(11 downto 0);
end package funcs;

package body funcs is 
	function piece_color(p: piece) return std_logic_vector(11 downto 0) is
	begin
		case (p) is
			when PIECE_A => return "111100000000";
			when PIECE_B => return "000011110000";
			when PIECE_C => return "000000001111";
			when PIECE_D => return "111111110000";
			when others => return "000000000000";
		end case;
	end;
end package body funcs;