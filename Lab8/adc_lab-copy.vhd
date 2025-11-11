library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_lab is 
	port (
		clk : in std_logic;
		HEX0 : out std_logic_vector(7 downto 0);
		HEX1 : out std_logic_vector(7 downto 0);
		HEX2 : out std_logic_vector(7 downto 0);
		KEY : in std_logic_vector(1 downto 0)
	);
end;

architecture behavior of adc_lab is
		type the_state is (IDLE, SEND);
		type MY_MEM is array (0 to 15) of std_logic_vector(7 downto 0);
	--										0		1			2		3		 4			5		6		 7 		8		9		 A      b		C		  d	  E		F
	constant table : MY_MEM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"90", x"88", X"83", X"A7", X"A1", X"86", X"8E");

		
		component pll_10mhz2
			PORT
			(
				inclk0		: IN STD_LOGIC  := '0';
				c0		: OUT STD_LOGIC ;
				locked		: OUT STD_LOGIC 
			);
		end component;
	
		component adc is
			port (
				adc_pll_clock_clk      : in  std_logic                     := 'X';             -- clk
				adc_pll_locked_export  : in  std_logic                     := 'X';             -- export
				clock_clk              : in  std_logic                     := 'X';             -- clk
				command_valid          : in  std_logic                     := 'X';             -- valid
				command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
				command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
				command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
				command_ready          : out std_logic;                                        -- ready
				reset_sink_reset_n     : in  std_logic                     := 'X';             -- reset_n
				response_valid         : out std_logic;                                        -- valid
				response_channel       : out std_logic_vector(4 downto 0);                     -- channel
				response_data          : out std_logic_vector(11 downto 0);                    -- data
				response_startofpacket : out std_logic;                                        -- startofpacket
				response_endofpacket   : out std_logic                                         -- endofpacket
			);
		end component adc;
		
	
	
	signal pll_locked : std_logic;
	signal counter : integer := 0;
	signal state : the_state;
	signal dummy, locked : integer;
	signal c10 : std_logic;
	signal reset_n : std_logic;
	signal valid, startofpacket, endofpacket, sink_reset : std_logic;
	signal ready, rsp_valid,  rs_sop, rs_eop : std_logic;
	signal rsp_channel, channel : std_logic_vector(4 downto 0);
	signal data : std_logic_vector(11 downto 0);
	signal buf : std_logic_vector(11 downto 0);
		
	begin
		P1: pll_10mhz2
			port map(
			inclk0 => clk,
			c0 => c10,
			locked => pll_locked
		);
		
		ADC1: adc
			port map(
				adc_pll_clock_clk      => c10,                               
				adc_pll_locked_export  => pll_locked,                             
				clock_clk   			  => clk,               
				command_valid          => valid,                         
				command_channel        => "00001",
				command_startofpacket  => startofpacket,                            
				command_endofpacket    => endofpacket,                         
				command_ready          => ready,                                        
				reset_sink_reset_n     => reset_n,                        
				response_valid         => rsp_valid,                                      
				response_channel       => open,                     
				response_data          => buf,                   
				response_startofpacket => open,                                      
				response_endofpacket   => open                                       
			);
		
		
		process(clk)
		begin
		
			if rising_edge(clk) then
				if KEY(0) = '0' then
					valid <= '0';
					state <= IDLE;
					data <= "000000000000";
					counter <= 0;
					startofpacket <= '0';
					endofpacket <= '0';
				else
					case(state) is
						when IDLE =>
							
							counter <= counter + 1;
							dummy <= 0;
							if counter > 50000000 then
								valid <= '1';
							end if;
							if ready = '1' then
								state <= SEND;
							end if;


						when SEND =>

							valid <= '0';
							dummy <= 1;

							
							if rsp_valid = '1' then
								state <= IDLE;
								counter <= 0;
								data <= buf;
							end if;
					end case;
				end if;
			
			end if;
			
			
		end process;
		reset_n <= KEY(0) and pll_locked;

		locked <= 1 when pll_locked = '1' else 0;
		
		HEX0 <= table(to_integer(unsigned(data(3 downto 0))));
		HEX1 <= table(to_integer(unsigned(data(7 downto 4))));
		HEX2 <= table(to_integer(unsigned(data(11 downto 8))));
	
end architecture behavior;