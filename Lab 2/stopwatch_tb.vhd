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
