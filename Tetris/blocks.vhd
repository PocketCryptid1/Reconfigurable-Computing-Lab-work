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
	constant BOARD_LEFT: integer := 176;
	constant BOARD_TOP: integer := 16;
	constant PIECE_SIZE: integer := 32;
	
	-- [SIGNALS] --
	signal active_col: integer range 0 to 8;
	signal active_row: integer range 0 to 14;
		
begin
	-- [DIRECT BEHAVIOR] --
	-- Calculate which column and row the pixel belongs to
	active_col <= (px_x - BOARD_LEFT) / PIECE_SIZE;
	active_row <= (px_y - BOARD_TOP) / PIECE_SIZE;
	
	-- [PROCESSES] --
		process (clk) begin
			if rising_edge(clk) then
				if px_x > 176 and px_x < 464 and px_y >= 0 and px_y < 464
				then
					case (active_board(active_row, active_col)) is
						when PIECE_A => 
							px_en <= '1';
							px_out <= piece_color(PIECE_A);
						when PIECE_B => 
							px_en <= '1';
							px_out <= piece_color(PIECE_B);
						when PIECE_C => 
							px_en <= '1';
							px_out <= piece_color(PIECE_C);
						when PIECE_D => 
							px_en <= '1';
							px_out <= piece_color(PIECE_D);
						when others =>
							px_en <= '0';
							px_out <= (others => '0');
					end case;
				else
					px_en <= '0';
					px_out <= (others => '0');
				end if;
			end if;
		end process;	
	
end architecture behavioral;











