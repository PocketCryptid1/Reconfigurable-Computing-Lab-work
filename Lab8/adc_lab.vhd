library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_lab is
	port (
		-- INPUTS --
		clk : in std_logic;
		
		-- INOUT --
		arduino_io : inout std_logic_vector(15 downto 0);
		arduino_reset_n : inout std_logic;
		
		-- OUTPUTS --
		hex0 : out std_logic_vector(7 downto 0);
		hex1 : out std_logic_vector(7 downto 0);
		hex2 : out std_logic_vector(7 downto 0);
	);
end entity adc_lab;

architecture behavioral is
	-- SIGNALS & CONSTANTS --
	signal clk_10mhz : std_logic;
	signal adc_out : std_logic_vector(11 downto 0);
	signal volt_count : unsigned(11 downto 0);
	
	-- COMPONENTS
	component seg
		 port(
			point   : in std_logic;
			count   : in unsigned(3 downto 0);
			output: out std_logic_vector(7 downto 0)
		 );
	component seg;
	
	component pll_10mhz is
		port (
			inclk0	: in std_logic  := '0';
			c0			: out std_logic
		);
	end component pll_10mhz;

begin

	-- INSTANCES --
	seg0_impl : seg port map(point => '0',  count => volt_count(3 downto 0), output => hex0);
	seg1_impl : seg port map(point => '0',  count => volt_count(7 downto 4), output => hex1);
	seg2_impl : seg port map(point => '0',  count => volt_count(11 downto 8), output => hex2);]

	pll_10mhz_impl : pll_10mhz port map (inclk0 => clk, c0 => clk_10mhz);

	-- DIRECT BEHAVIOR --
	volt_count <= unsigned(adc_out);

	

end architecture behavioral;