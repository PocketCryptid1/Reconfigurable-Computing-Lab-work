------ SEVEN SEGMENT DECODER ------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity segdecode is
	port(
		point: 		in  std_logic;
		bcd:  		in	std_logic_vector(3 downto 0);
		display: 	out std_logic_vector(7 downto 0)
	);
end entity segdecode;

architecture behavioral of segdecode is
	signal sevenseg : std_logic_vector(6 downto 0);
	begin
		process (bcd) begin
			case(bcd) is
				when "0000" => sevenseg <= "1000000"; --0
				when "0001" => sevenseg <= "1111001"; --1
				when "0010" => sevenseg <= "0100100"; --2
				when "0011" => sevenseg <= "0110000"; --3
				when "0100" => sevenseg <= "0011001"; --4
				when "0101" => sevenseg <= "0010010"; --5
				when "0110" => sevenseg <= "0000010"; --6
				when "0111" => sevenseg <= "1111000"; --7
				when "1000" => sevenseg <= "0000000"; --8
				when "1001" => sevenseg <= "0011000"; --9
				when "1010" => sevenseg <= "0001000"; --A
				when "1011" => sevenseg <= "0000011"; --B
				when "1100" => sevenseg <= "1000110"; --C
				when "1101" => sevenseg <= "0100001"; --D
				when "1110" => sevenseg <= "0000110"; --E
				when "1111" => sevenseg <= "0001110"; --F
			end case;
			display <= sevenseg & point;
		end process;
end architecture behavioral;

------ STOPWATCH TOP LEVEL MODULE ------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Stopwatch is
	port(

	--CLOCK
   MAX10_CLK1_50 : in std_logic; -- The main clock source that we will be using

	--SEG7
	HEX0 : out std_logic_vector(7 downto 0);
	HEX1 : out std_logic_vector(7 downto 0);
	HEX2 : out std_logic_vector(7 downto 0);
	HEX3 : out std_logic_vector(7 downto 0);
	HEX4 : out std_logic_vector(7 downto 0);
	HEX5 : out std_logic_vector(7 downto 0);
	
	--KEY
	KEY : in std_logic_vector(1 downto 0) -- The buttons input
	);
end entity Stopwatch;

architecture behavioral of Stopwatch is
	-- CONSTANTS --
	--clk is 50Mhz need 100 hz 
	constant MAX_COUNT : integer :=500_000;

	-- SIGNALS --
	--values to send to seven segments
	signal hundreths	: unsigned(6 downto 0);
	signal secs 		: unsigned(5 downto 0);
	signal mins			: unsigned(5 downto 0);
	-- for use instead of a clock divider
	signal count 		: unsigned(18 downto 0);

	component segdecode
		port (
			point: 		in  std_logic;
			bcd:  		in	 std_logic_vector(3 downto 0);
			display: 	out std_logic_vector(7 downto 0)
		);
	end component segdecode;

begin
	process (MAX10_CLK1_50) begin
		if rising_edge(MAX10_CLK1_50) then
			-- only on 100hz clock
			if count = (MAX_COUNT - 1) then
				count <= (others => '0');
					case KEY is
						when "00" => --hold
						when "01" => --reset
							hundreths <= (others => '0');
							secs <= (others => '0');
							mins <= (others => '0');
						when "10" => --run
							--cascading counters for hundreths, seconds, minutes
							--hudnreths
							if hundreths = "1001100" then --99
								hundreths <= (others => '0');

								--seconds
								if secs = "111011" then --59
									secs <= (others => '0');

									--minutes
									if mins = "111011" then --59
										mins <= (others => '0');
									else
										mins <= mins + 1;
									end if;
									--end minutes
								else
									secs <= secs + 1;
								end if;
								--end seconds
							else
								hundreths <= hundreths + 1;
							end if;
							--end hundreths
						when others => --invalid key state, do nothing
					end case;
			-- end active clock tick				
			else
				count <= count + 1;
			end if;
		end if;
	end process;
		-- send values to seven segments
	S0: segdecode
		port map(
			point => '0',
			bcd => std_logic_vector(hundreths mod 10)(3 downto 0), 
			display => HEX0
		);
	S1: segdecode
		port map(
			point => '0',
			bcd => std_logic_vector(hundreths / 10)(3 downto 0), 
			display => HEX1
		);
	S2: segdecode
		port map(
			point => '1',
			bcd => std_logic_vector(secs mod 10)(3 downto 0), 
			display => HEX2
		);
	S3: segdecode
		port map(
			point => '0',
			bcd => std_logic_vector(secs / 10)(3 downto 0), 
			display => HEX3
		);
	S4: segdecode
		port map(
			point => '1',
			bcd => std_logic_vector(mins mod 10)(3 downto 0), 
			display => HEX4
		);
	S5: segdecode
		port map(
			point => '0',
			bcd => std_logic_vector(mins / 10)(3 downto 0), 
			display => HEX5
		);
end architecture behavioral;