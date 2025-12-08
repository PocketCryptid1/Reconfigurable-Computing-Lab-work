library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package main is 
	type piece is (NONE, PIECE_A, PIECE_B, PIECE_C, PIECE_D);
	type game_board is array (8 downto 0, 14 downto 0) of piece;

	function piece_color(p: in piece) return std_logic_vector(11 downto 0);
end package main;

package body main is 
	function piece_color(p: in piece) return std_logic_vector(11 downto 0) is
	begin
		case (p) is
			when NONE => return "000000000000";
			when PIECE_A => return "111100000000";
			when PIECE_B => return "000011110000";
			when PIECE_C => return "000000001111";
			when PIECE_D => return "111111110000";
		end case;
	end;
end package body main;