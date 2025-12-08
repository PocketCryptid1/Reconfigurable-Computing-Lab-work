library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.main.all;
use work.funcs.all;

entity blocks is
	port(
		-- [INPUTS] --
		clk: in std_logic;
		px_x: in integer range 0 to 639;
		px_y: in integer range 0 to 479;
		
		active_board: in game_board;
		
		-- [OUTPUTS] --
		px_en: out std_logic;
		px_out: out std_logic_vector(11 downto 0)
	);	
end entity blocks;

architecture behavioral of blocks is
	-- [TYPES] --
	
	-- [CONSTANTS] --
	
	-- [SIGNALS] --

begin
	-- [DIRECT BEHAVIOR] --
	
	-- [PROCESSES] --
	for row in 0 to 15 generate begin
		for col in 0 to 9 generate begin
			
		end generate;
	end generate;
	
end architecture behavioral;











