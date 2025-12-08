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
	signal active_col: integer range 0 to 8;
	signal active_row: integer range 0 to 14;
		
begin
	-- [DIRECT BEHAVIOR] --
	active_col <= (px_x - 176) / 32;
	active_row <= (px_y - 16) / 32;
	
	-- [PROCESSES] --
		process (clk) begin
			if rising_edge(clk) then
				if px_x > 176 and px_x < 464 and px_y > 16 and px_y < 464
				then
					px_en <= '1';
					px_out <= piece_color(active_board(active_row, active_col));
				else
					px_en <= '0';
					px_out <= (others => '0');
				end if;
			end if;
		end process;	
	
end architecture behavioral;











