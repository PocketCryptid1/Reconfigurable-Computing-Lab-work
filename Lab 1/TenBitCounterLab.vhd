library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Main entity module for this lab
entity TenBitCounterLab is
	port (
		ADC_CLK_10 : in std_logic;	-- We do not need this clock
		MAX10_CLK1_50 : in std_logic; -- The main clock source that we will be using
		MAX10_CLK2_50 : in std_logic; -- We do not need this clock
		KEY : in std_logic_vector(1 downto 0); -- The buttons input
		LEDR : out unsigned(9 downto 0) -- The outputing LEDs
	);
end entity TenBitCounterLab;
	
architecture behavioral of TenBitCounterLab is
	-- [CONSTANTS]
	-- Declares the max value the counter should be before incrementing the LEDs by one.
	-- Clk is 50Mhz, so to meet 2Hz, max is 25 million
	constant MAX_COUNT : integer := 25_000_000;

	-- [SIGNALS] --
	-- Contains the current output to the LEDs
	signal output : unsigned(9 downto 0);
	-- Contains the current count of the counter. Use in place of a clock divider
	signal count : unsigned(24 downto 0);

	begin
		-- Sensitive to the buttons (reset) or the clock
		process (MAX10_CLK1_50, KEY) begin
			-- Reset case
			if KEY(0) = '0' then
				count <= (others => '0');
				output <= (others => '0');
		
			-- Rising edge of clock case
			elsif rising_edge(MAX10_CLK1_50) then
				-- If the count is set to the maximum, increment the LEDs by one
				if count = (MAX_COUNT - 1) then
					count <= (others => '0');
					output <= output + 1;
					
				-- Otherwise, count as normal
				else
					count <= count + 1;
					
				end if;
			end if;
		end process;
		
		-- Set the LEDs to the output
		LEDR <= output;
end architecture behavioral;