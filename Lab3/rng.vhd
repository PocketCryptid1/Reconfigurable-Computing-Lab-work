library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng is 
	port(
		-- [Inputs] --
		ADC_CLK_10: in std_logic;
		KEY: in std_logic_vector(1 downto 0);
		
		-- [Outputs] --
		HEX0: out std_logic_vector(7 downto 0);
		HEX1: out std_logic_vector(7 downto 0)
	);	
end entity rng;

architecture behavioral of rng is
	-- [COMPONENTS] --
	component seg
		port(
			point: in std_logic;
			count: in std_logic_vector(3 downto 0);
			display: out std_logic_vector(7 downto 0)
		);
	end component seg;
	
	component lfsr_8bit
		port(
			clk : in std_logic;
			rst_l : in std_logic;
			enabled : in std_logic;
			seed : in std_logic_vector(7 downto 0);
			result: out std_logic_vector(7 downto 0)
		);
	end component lfsr_8bit;
	
	-- [SIGNALS] --
	signal clk_count : unsigned(7 downto 0);
	signal count_vector : std_logic_vector(7 downto 0);
	
	signal lfsr_out_vector : std_logic_vector(7 downto 0) := (others => '0');
	
	signal seg0_out_vector : std_logic_vector(3 downto 0);
	signal seg1_out_vector : std_logic_vector(3 downto 0);
	
begin
	-- [INSTANCES] --
	seg0_impl : seg port map(
		point => '0',
		count => seg0_out_vector,
		display => HEX0
	);
	
	seg1_impl: seg port map(
		point => '0',
		count => seg1_out_vector,
		display => HEX1
	);
	
	lfsr_impl : lfsr_8bit port map(
		clk => ADC_CLK_10,
		rst_l => KEY(0),
		enabled => KEY(1),
		seed => count_vector,
		result => lfsr_out_vector
	);
	
	-- [EXTERNAL BEHAVIOR] --
	count_vector <= std_logic_vector(clk_count);
	
	-- [PROCESSES] --
	process (ADC_CLK_10, KEY)
	begin
		if KEY = "10" then
			-- reset
			clk_count <= (others => '0');
			
		elsif rising_edge(ADC_CLK_10) and KEY = "11" then
			-- neither button is pressed, increase the count (the seed)
			clk_count <= clk_count + 1;
		end if;
		
		if KEY = "11" then
			-- no key is being pressed
			seg0_out_vector <= lfsr_out_vector(3 downto 0);
			seg1_out_vector <= lfsr_out_vector(7 downto 4);
		else
			seg0_out_vector <= (others => '0');
			seg1_out_vector <= (others => '0');
		end if;
	end process;

end architecture behavioral;
