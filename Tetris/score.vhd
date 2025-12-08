library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity score is
	port(
		-- [INPUTS] --
		clk: in std_logic;
		px_x: in integer range 0 to 639;
		px_y: in integer range 0 to 479;
		score_in: in std_logic_vector(23 downto 0);
		
		-- [OUTPUTS] --
		px_en: out std_logic;
		px_out: out std_logic_vector(11 downto 0)
	);	
end entity score;

architecture behavioral of score is
	-- [TYPES] --
	
	-- [CONSTANTS] --
	constant V_OFFSET: integer := 400;
	constant H_OFFSET: integer := 500;
	constant CHAR_WIDTH: integer := 16;
	constant CHAR_HEIGHT: integer := 24;
	constant CHAR_SPACING: integer := 4;
	-- [SIGNALS] --

begin
	-- [DIRECT BEHAVIOR] --
	
	-- [PROCESSES] --
	process(clk) is
		variable digit: integer range 0 to 15;
		variable char_x: integer range 0 to CHAR_WIDTH - 1;
		variable char_y: integer range 0 to CHAR_HEIGHT - 1;
		variable score_digit: integer range 0 to 5;
		variable score_value: integer;
	begin
		if rising_edge(clk) then
			-- Default output
			px_en <= '0';
			px_out <= (others => '0');
			-- Check if within score area
			if (px_y >= V_OFFSET) and (px_y < V_OFFSET + CHAR_HEIGHT) then
				if (px_x >= H_OFFSET) and (px_x < H_OFFSET + (6 * (CHAR_WIDTH + CHAR_SPACING))) then
					-- Determine which hex digit we're on (6 hex digits for 24-bit input)
					score_value := to_integer(unsigned(score_in));

					-- score_digit: 5 down to 0 from leftmost to rightmost
					score_digit := 5 - ((px_x - H_OFFSET) / (CHAR_WIDTH + CHAR_SPACING));

					-- Extract hex digit: divide by 16^(score_digit) and mask lower 4 bits
					digit := (score_value / (16 ** score_digit)) mod 16;

					-- Determine character pixel coordinates
					char_x := (px_x - H_OFFSET) mod (CHAR_WIDTH + CHAR_SPACING);
					char_y := px_y - V_OFFSET;

					-- Check if within character pixel area
					if char_x < CHAR_WIDTH then

						-- Enable pixel output
						px_en <= '1';
						-- Determine pixel color based on digit
						case digit is
							when 0 =>
								--if ( (char_y = 0 ) or (char_y = 24)
								--or (char_x = 0) or (char_x = 16)) then
								--	px_out <= "111111111111"; -- White for digit 0
								elsif ( char_y = 0)
									then
									px_out <= "111100000000";
								elsif (char_y = 24)
									then
									px_out <= "000011110000";
								elsif (char_x = 0)
									then
									px_out <= "111100001111";
								elsif (char_x = 16)
									then
									px_out <= "000011111111";
								else
									px_out <= (others => '0');
								end if;
							when 1 =>
								if (char_x = 24) then
									px_out <= "111111111111"; -- White for digit 1
								else
									px_out <= (others => '0');
								end if;
							when 2 =>
								if ( (char_y = 0) or (char_x = 16 and char_y < 12)
								or (char_y = 12) or (char_x = 0 and char_y > 12)
								or (char_y = 24)) then
									px_out <= "111111111111"; -- White for digit 2
								else
									px_out <= (others => '0');
								end if;
							when 3 =>
								if ( (char_y = 0) or (char_y = 12) or (char_y = 24)
								or (char_x = 16) ) then
									px_out <= "111111111111"; -- White for digit 3
								else
									px_out <= (others => '0');
								end if;
							when 4 =>
								if ( ( (char_x = 4) and (char_y >= 0 and char_y < 14) ) or
									 ( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_x = 11) and (char_y >= 0 and char_y < 24) ) ) then
									px_out <= "111111111111"; -- White for digit 4
								else
									px_out <= (others => '0');
								end if;
							when 5 =>
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 20 and char_y < 24) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_x = 4 or char_x = 11) and (char_y >= 4 and char_y < 20) ) ) then
									px_out <= "111111111111"; -- White for digit 5
								else
									px_out <= (others => '0');
								end if;	
							when 6 =>
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 20 and char_y < 24) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_x = 4) and (char_y >= 4 and char_y < 20) ) or
									 ( (char_x = 11) and (char_y >= 10 and char_y < 20) ) ) then
									px_out <= "111111111111"; -- White for digit 6
								else
									px_out <= (others => '0');
								end if;
							when 7 =>
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_x = 11) and (char_y >= 0 and char_y < 24) ) ) then
									px_out <= "111111111111"; -- White for digit 7
								else
									px_out <= (others => '0');
								end if;
							when 8 =>
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 20 and char_y < 24) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_x = 4 or char_x = 11) and (char_y >= 4 and char_y < 20) ) ) then
									px_out <= "111111111111"; -- White for digit 8
								else
									px_out <= (others => '0');
								end if;
							when 9 =>
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_y >= 20 and char_y <24) and (char_x >= 4 and char_x < 12) ) or
									 ( (char_x = 11) and (char_y >= 4 and char_y < 20) ) or
									 ( (char_x = 4) and (char_y >= 0 and char_y < 10) ) ) then
									px_out <= "111111111111"; -- White for digit 9
								else
									px_out <= (others => '0');
								end if;
							when 10 => -- A
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									( (char_y >= 4 and char_y < 20) and (char_x = 4 or char_x = 11) ) or
									( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) ) then
									px_out <= "111111111111"; -- White for 'A'
								else
									px_out <= (others => '0');
								end if;
							when 11 => -- B (render as b)
								if ( ( (char_y >= 0 and char_y < 24) and (char_x = 4) ) or
									( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 11) ) or
									( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 11) ) or
									( (char_y >= 20 and char_y < 24) and (char_x >= 4 and char_x < 11) ) or
									( (char_x = 11) and ((char_y >= 4 and char_y < 10) or (char_y >= 14 and char_y < 20)) ) ) then
									px_out <= "111111111111"; -- White for 'b'
								else
									px_out <= (others => '0');
								end if;
							when 12 => -- C
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									( (char_y >= 4 and char_y < 20) and (char_x = 4) ) or
									( (char_y >= 20 and char_y < 24) and (char_x >= 4 and char_x < 12) ) ) then
									px_out <= "111111111111"; -- White for 'C'
								else
									px_out <= (others => '0');
								end if;
							when 13 => -- D (render as d)
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 11) ) or
									( (char_y >= 4 and char_y < 20) and (char_x = 11) ) or
									( (char_y >= 4 and char_y < 20) and (char_x = 4) ) or
									( (char_y >= 20 and char_y < 24) and (char_x >= 4 and char_x < 11) ) ) then
									px_out <= "111111111111"; -- White for 'd'
								else
									px_out <= (others => '0');
								end if;
							when 14 => -- E
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) or
									( (char_y >= 20 and char_y < 24) and (char_x >= 4 and char_x < 12) ) or
									( (char_x = 4) and (char_y >= 4 and char_y < 20) ) ) then
									px_out <= "111111111111"; -- White for 'E'
								else
									px_out <= (others => '0');
								end if;
							when 15 => -- F
								if ( ( (char_y >= 0 and char_y < 4) and (char_x >= 4 and char_x < 12) ) or
									( (char_y >= 10 and char_y < 14) and (char_x >= 4 and char_x < 12) ) or
									( (char_x = 4) and (char_y >= 4 and char_y < 20) ) ) then
									px_out <= "111111111111"; -- White for 'F'
								else
									px_out <= (others => '0');
								end if;
							when others =>
								px_out <= (others => '0');	
						end case;
					end if;
				end if;
			end if;
		end if;
	end process;
end architecture behavioral;











