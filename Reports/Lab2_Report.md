---
title: "Lab 2"
author: "Carter Owens, Kyle Turley"
geometry: margin=2cm
---

## Procedures

**Introduction.** The goal of this lab is to design, implement, and test a Stopwatch. constraints for this lab is to utilize the 50MHz internal clock and have the stopwatch track within a 100th of a second. we also cannot use a clock divider.

The procedures for this lab are as follows

1. Create a Quartus project using the System Builder application
2. Create an initial implementation of the stopwatch
3. Create a testbench to test the ten-bit counter & verify correct behavior
4. Compile and load the counter onto the FPGA for visual confirmation

**Issues and Errors.** We continued to have issues with Questa and the waveform not updating in the waveform viewer. While we know that the design is operating correctly, the Questa waveform continues to fail in providing a waveform that changes overtime. The initial conditions of the output segments displays is properly reflected; however, as the reset values changes, the circuit seems to fail in response. Ultimately, when comparing our design with our peers, we are confident in the design of the testbench and the required entities-- we feel the issue is from our local configuration and script execution. We require assistance in these areas and hope that we have demonstrated understanding of this software to meet expectations. We will continue to monitor these issues and communicate any questions with the professor.

**Stumbles.** We ran into multiple issues. Firstly, the simulation consistently gave us warnings that the "=" of an unsigned type would always result in a FALSE value. This issue was addressed, and the warning was corrected. However, this did not fix our simulation errors. Next, we realized that we were slightly counting too fast, where a second was being counted ever 0.79 seconds. This was corrected by implementing the correct value in our timing logic. 

## Results

We first used an internal counter to convert the 50 MHz clock to count 100ths of a second, we then created a module that converts a binary number into a seven segment output.

## Figures and Code

The following is the main module file that contains 7-segment and stopwatch entity architecture.
```
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
				when others => sevenseg <= "0000000"; --8
			end case;
			display <= point & sevenseg;
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
	constant MAX_COUNT : integer := 10;

	-- SIGNALS --
	--values to send to seven segments
	signal hundreths	: unsigned(6 downto 0);
	signal secs 		: unsigned(5 downto 0);
	signal mins			: unsigned(5 downto 0);
	-- for use instead of a clock divider
	signal count 		: integer;
	
	-- intermediate signals for the segment displays
	signal bcd_hex0: std_logic_vector(3 downto 0);
	signal bcd_hex1: std_logic_vector(3 downto 0);
	signal bcd_hex2: std_logic_vector(3 downto 0);
	signal bcd_hex3: std_logic_vector(3 downto 0);
	signal bcd_hex4: std_logic_vector(3 downto 0);
	signal bcd_hex5: std_logic_vector(3 downto 0);

	component segdecode
		port (
			point: 		in  std_logic;
			bcd:  		in	 std_logic_vector(3 downto 0);
			display: 	out std_logic_vector(7 downto 0)
		);
	end component segdecode;
begin
	S0: segdecode
		port map(
			point => '1',
			bcd => bcd_hex0, 
			display => HEX0
		);
	S1: segdecode
		port map(
			point => '1',
			bcd => bcd_hex1, 
			display => HEX1
		);
	S2: segdecode
		port map(
			point => '0',
			bcd => bcd_hex2, 
			display => HEX2
		);
	S3: segdecode
		port map(
			point => '1',
			bcd => bcd_hex3, 
			display => HEX3
		);
	S4: segdecode
		port map(
			point => '0',
			bcd => bcd_hex4, 
			display => HEX4
		);
	S5: segdecode
		port map(
			point => '1',
			bcd => bcd_hex5, 
			display => HEX5
		);

	process (MAX10_CLK1_50) begin
		if rising_edge(MAX10_CLK1_50) then
			-- only on 100hz clock
			if count >= (MAX_COUNT - 1) then
				count <= 0;
				case KEY is
					when "00" => --hold
					when "01" => --reset
						hundreths <= (others => '0');
						secs <= (others => '0');
						mins <= (others => '0');
					when "10" => --run
						--cascading counters for hundreths, seconds, minutes
						--hudnreths
						if hundreths = 99 then --99
							hundreths <= (others => '0');

							--seconds
							if secs = 59 then --59
								secs <= (others => '0');

								--minutes
								if mins = 59 then --59
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
		
		bcd_hex0 <= std_logic_vector(resize(hundreths mod 10, 4));
		bcd_hex1 <= std_logic_vector(resize(hundreths / 10, 4));
		bcd_hex2 <= std_logic_vector(resize(secs mod 10, 4));
		bcd_hex3 <= std_logic_vector(resize(secs / 10, 4));
		bcd_hex4 <= std_logic_vector(resize(mins mod 10, 4));
		bcd_hex5 <= std_logic_vector(resize(mins / 10, 4));
	end process;	
end architecture behavioral;
```

The following code represents the stopwatch testbench.
```
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch_tb is
end stopwatch_tb;

architecture behavioral of stopwatch_tb is
		component Stopwatch
			port (
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
		end component;
		
		signal clk   : std_logic := '0';
		signal rst_l : std_logic_vector(1 downto 0) := (others => '0');
		
		signal hex0 : std_logic_vector(7 downto 0);
		signal hex1 : std_logic_vector(7 downto 0);
		signal hex2 : std_logic_vector(7 downto 0);
		signal hex3 : std_logic_vector(7 downto 0);
		signal hex4 : std_logic_vector(7 downto 0);
		signal hex5 : std_logic_vector(7 downto 0);
		
		constant CLK_PERIOD : time := 1 ns;
		
begin
	uut : Stopwatch
	port map(
		MAX10_CLK1_50 => clk,
		KEY => rst_l,
		
		HEX0 => hex0,
		HEX1 => hex1,
		HEX2 => hex2,
		HEX3 => hex3,
		HEX4 => hex4,
		HEX5 => hex5
	);
	
	clk_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process;
	
	rst_process : process
	begin		
		-- "00" => hold
		-- "01" => reset
		-- "10" => run
	
		rst_l <= "01";
		wait for clk_period * 11;
		
		rst_l <= "00";
		wait for clk_period * 10;
		
		rst_l <= "10";
		wait;
	end process;
end architecture behavioral;
```

The following image shows the simulation of the design through Questa.
![Questa Simulation](SIM.png "Questa Simulation")

## Conclusion
This lab has demonstrated our understanding of separate arithmetic logic from clock logic within the FPGA. In addition, this lab as provided more insight into gaps of our knowledge. 
