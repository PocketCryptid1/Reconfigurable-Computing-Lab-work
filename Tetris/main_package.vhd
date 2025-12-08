library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package main is 
	type piece is (NONE, PIECE_A, PIECE_B, PIECE_C, PIECE_D, DROP_A, DROP_B, DROP_C, DROP_D);
	type game_board is array (14 downto 0, 8 downto 0) of piece;
end package main;