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
		row_gen: for row in 14 downto 0 generate begin
			col_gen: for col in 8 downto 0 generate begin
				process (clk) begin
					if rising_edge(clk) then
						if x > 176 + col*32 and x < 176 + (col+1)*32 and 
							y > 464 - (16-row)*32 and y < 464 + (15-row)*32 
						then
							px_en <= '1';
							px_out <= piece_color(active_board(row,col));
						else
							px_en <= '0';
							px_out <= (others => '0');
						end if;
					end if;
				end process;	
			end generate;
		end generate;
	
end architecture behavioral;











