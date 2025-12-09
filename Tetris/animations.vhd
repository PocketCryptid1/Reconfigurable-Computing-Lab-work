library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.main.all;
use work.funcs.all;

entity animations is
	port(
		-- [INPUTS] --
		clk: in std_logic;
		px_x: in integer range 0 to 639;
		px_y: in integer range 0 to 479;
		
		do_drop: in std_logic;
		piece: in piece;
		drop_x: in integer range 0 to 9;
		drop_y: in integer range 0 to 16;
		
		-- [OUTPUTS] --
		px_en: out std_logic;
		px_out: out std_logic_vector(11 downto 0)
	);	
end entity animations;

architecture behavioral of animations is
	-- [TYPES] --
	
	-- [CONSTANTS] --
	
	-- [SIGNALS] --

begin
	-- [DIRECT BEHAVIOR] --
	
	-- [PROCESSES] --
	process (clk) begin
		if rising_edge(clk) and do_drop = '1' then
			if px_x >= drop_x and px_x <= drop_x + 32 and 
				px_y >= drop_y and px_y <= drop_y + 32
			then
				px_en <= '1';
				px_out <= drop_color(piece);
			else
				px_en <= '0'
				px_out <= (others => '0');
			end if;
		end if;
	end process;
	
end architecture behavioral;











