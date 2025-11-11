library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_lab is
	port (
		-- INPUTS --
		clk : in std_logic;

		
		-- OUTPUTS --
		hex0 : out std_logic_vector(7 downto 0);
		hex1 : out std_logic_vector(7 downto 0);
		hex2 : out std_logic_vector(7 downto 0)
	);
end entity adc_lab;

architecture behavioral of adc_lab is
	-- SIGNALS & CONSTANTS --
	signal clk_10mhz : std_logic;
	signal adc_out : std_logic_vector(11 downto 0);
	signal volt_count : unsigned(11 downto 0) := (others => '0');
	
	signal count_1hz : integer range 0 to 50_000_000 := 0;
	signal cmd_valid : std_logic := '0';
	signal cmd_ready : std_logic;
	signal resp_valid : std_logic;
	signal resp_data : std_logic_vector(11 downto 0);
	
	-- COMPONENTS
	component seg
		 port(
			point   : in std_logic;
			count   : in unsigned(3 downto 0);
			output: out std_logic_vector(7 downto 0)
		 );
	end component seg;
	
	component pll_10mhz is
		port (
			inclk0	: in std_logic  := '0';
			c0			: out std_logic
		);
	end component pll_10mhz;

	component adc is
		port (
			clock_clk              : in  std_logic                     := 'X';             -- clk
			reset_sink_reset_n     : in  std_logic                     := 'X';             -- reset_n
			adc_pll_clock_clk      : in  std_logic                     := 'X';             -- clk
			adc_pll_locked_export  : in  std_logic                     := 'X';             -- export
			command_valid          : in  std_logic                     := 'X';             -- valid
			command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
			command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			command_ready          : out std_logic;                                        -- ready
			response_valid         : out std_logic;                                        -- valid
			response_channel       : out std_logic_vector(4 downto 0);                     -- channel
			response_data          : out std_logic_vector(11 downto 0);                    -- data
			response_startofpacket : out std_logic;                                        -- startofpacket
			response_endofpacket   : out std_logic                                         -- endofpacket
		);
	end component adc;

begin

	-- INSTANCES --
	seg0_impl : seg port map(point => '0',  count => volt_count(3 downto 0), output => hex0);
	seg1_impl : seg port map(point => '0',  count => volt_count(7 downto 4), output => hex1);
	seg2_impl : seg port map(point => '0',  count => volt_count(11 downto 8), output => hex2);

	pll_10mhz_impl : pll_10mhz port map (inclk0 => clk, c0 => clk_10mhz);

	adc_impl : adc
		port map (
			clock_clk              => clk,                     --          clock.clk
			reset_sink_reset_n     => '1',                     --     reset_sink.reset_n
			adc_pll_clock_clk      => clk_10mhz,               --  adc_pll_clock.clk
			adc_pll_locked_export  => '1',                     -- adc_pll_locked.export
			command_valid          => cmd_valid,               --        command.valid
			command_channel        => "00000",                 --               .channel
			command_startofpacket  => '1',                     --               .startofpacket
			command_endofpacket    => '1',                     --               .endofpacket
			command_ready          => cmd_ready,               --               .ready
			response_valid         => resp_valid,              --       response.valid
			response_channel       => open,                    --               .channel
			response_data          => resp_data,               --               .data
			response_startofpacket => open,                    --               .startofpacket
			response_endofpacket   => open                     --               .endofpacket
		);

	-- DIRECT BEHAVIOR --
	
	process (clk) begin
		if rising_edge(clk) then
			-- Issue ADC command when ready
			if cmd_ready = '1' then
				cmd_valid <= '1';
			else
				cmd_valid <= '0';
			end if;
			
			-- Latch response data when valid
			if resp_valid = '1' then
				volt_count <= unsigned(resp_data);
			end if;
		end if;
	end process;
	
end architecture behavioral;