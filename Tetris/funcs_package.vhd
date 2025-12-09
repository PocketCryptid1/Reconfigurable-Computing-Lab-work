library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.main.all;

package funcs is 
	subtype color_out is std_logic_vector(11 downto 0);
	
	function piece_color(p: piece) return color_out;
	function drop_color(p: piece) return color_out;
	function to_piece(p: piece) return piece;
	
end package funcs;

package body funcs is 
	function piece_color(p: piece) return color_out is
	begin
		case (p) is
			when PIECE_A => return "111100000000";
			when PIECE_B => return "000011110000";
			when PIECE_C => return "000000001111";
			when PIECE_D => return "111111110000";
			when others => return "000000000000";
		end case;
	end;
	
	function drop_color(p: piece) return color_out is
	begin
		case (p) is
			when DROP_A => return "111100000000";
			when DROP_B => return "000011110000";
			when DROP_C => return "000000001111";
			when DROP_D => return "111111110000";
			when others => return "000000000000";
		end case;
	end;
	
	function to_piece(p: piece) return piece is
	begin
		case (p) is
			when DROP_A => PIECE_A;
			when DROP_B => PIECE_B;
			when DROP_C => PIECE_C;
			when DROP_D => PIECE_D;
			when others => p;
		end case;
	end;
end package body funcs;