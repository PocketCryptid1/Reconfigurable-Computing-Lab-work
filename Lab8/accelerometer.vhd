library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accelerometer is
	port (
		-- INPUTS --
		clk : in std_logic;
		gsensor_int : in std_logic_vector(2 downto 1);
		
		-- INOUTS --
		gsensor_sdi	: inout std_logic;
		gsensor_sdo : inout std_logic;
		
		-- OUTPUTS --
		hex0 : out std_logic_vector(7 downto 0);
		hex1 : out std_logic_vector(7 downto 0);
		hex2 : out std_logic_vector(7 downto 0);
		hex3 : out std_logic_vector(7 downto 0);
		hex4 : out std_logic_vector(7 downto 0);
		hex5 : out std_logic_vector(7 downto 0);
		
		gsensor_cs_n : out std_logic;
		gsensor_sclk : out std_logic;
	);
end entity accelerometer;

architecture behavioral is
	-- SIGNALS & CONSTANTS --
	
	-- COMPONENTS


begin

	-- INSANT --

	-- DIRECT BEHAVIOR --


end architecture behavioral;
