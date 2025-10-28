library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
	port(
		-- [INPUTS] --
		ADC_CLK_10	: in std_logic;								-- System clock
		KEY			: in std_logic_vector(1 downto 0);		-- The pressable buttons
		SW				: in unsigned(9 downto 0);					-- The 10 switches

		-- [OUTPUTS] --
		HEX0			: out std_logic_vector(7 downto 0);		-- Segment display outs:
		HEX1			: out std_logic_vector(7 downto 0);
		HEX2			: out std_logic_vector(7 downto 0);
		HEX3			: out std_logic_vector(7 downto 0);
		HEX4			: out std_logic_vector(7 downto 0);
		HEX5			: out std_logic_vector(7 downto 0);
		
		LEDR			: out unsigned(9 downto 0)					-- The 10 output LEDs
	);
end entity accumulator;

architecture behavioral of accumulator is
	-- [COMPONENTS] --
	component seg
		port(
			point	: in std_logic;
			count	: in unsigned(3 downto 0);
			output: out std_logic_vector(7 downto 0)
		);
	end component seg;
	
	component debounce
		port(
			clk 	: in std_logic;
			d_in 	: in std_logic;
			d_out : out std_logic
		);
	end component debounce;
	
	component fifo is
		port (
			aclr		: in std_logic;
			data		: IN std_logic_vector (9 downto 0);
			rdclk		: in std_logic;
			rdreq		: in std_logic;
			wrclk		: in std_logic;
			wrreq		: in std_logic;
			q			: out std_logic_vector (9 downto 0);
			rdusedw	: out std_logic_vector (2 downto 0);
			wrusedw	: out std_logic_vector (2 downto 0)
		);
	end component fifo;
	
	component pll5mhz IS
		port (
			areset	: in std_logic;
			inclk0	: in std_logic;
			c0			: out std_logic;
			locked	: out std_logic 
		);
	end component pll5mhz;
	
	component pll12_5mhz IS
		port (
			areset	: in std_logic;
			inclk0	: in std_logic;
			c0			: out std_logic;
			locked	: out std_logic 
		);
	end component pll12_5mhz;

	-- [SIGNALS & CONSTANTS] --
	signal key_inverted 	 : std_logic_vector(1 downto 0);
	signal rst_master  	 : std_logic := '0';
	
	-- clocks
	signal clk_5mhz	 : std_logic;
	signal locked_5mhz : std_logic;
	
	signal clk_12_5mhz 	 : std_logic;
	signal locked_12_5mhz : std_logic;
	
	-- fifo signals
	signal fifo_in 			: std_logic_vector (9 downto 0) := (others => '0');
	signal fifo_out 			: std_logic_vector (9 downto 0);
	signal fifo_read 			: std_logic := '0';
	signal fifo_write 		: std_logic := '0';
	signal fifo_read_count 	: std_logic_vector (2 downto 0);
	
	signal psh_db 	: std_logic;
	signal rst_db 	: std_logic;
	signal count 	: unsigned(23 downto 0) := (others => '0');
	
	signal a_current_state  : std_logic_vector(1 downto 0) := "00";
	signal a_next_state	 	: std_logic_vector(1 downto 0) := "00";
	
	signal b_current_state  : std_logic_vector(1 downto 0) := "00";
	signal b_next_state 		: std_logic_vector(1 downto 0) := "00";
	
	constant A_IDLE : std_logic_vector(1 downto 0) := "00";
	constant A_RST  : std_logic_vector(1 downto 0) := "01";
	constant A_PUSH : std_logic_vector(1 downto 0) := "10";
	constant A_HOLD : std_logic_vector(1 downto 0) := "11";
	
	constant B_IDLE : std_logic_vector(1 downto 0) := "00";
	constant B_PULL : std_logic_vector(1 downto 0) := "01";
	constant B_RST  : std_logic_vector(1 downto 0) := "10";
	
begin
	-- [INSTANCES] --
	seg0_impl : seg port map(point => '0',	count => count(3 downto 0), output => HEX0);
	seg1_impl : seg port map(point => '0',	count => count(7 downto 4), output => HEX1);
	seg2_impl : seg port map(point => '0',	count => count(11 downto 8), output => HEX2);
	seg3_impl : seg port map(point => '0',	count => count(15 downto 12), output => HEX3);
	seg4_impl : seg port map(point => '0',	count => count(19 downto 16), output => HEX4);
	seg5_impl : seg port map(point => '0',	count => count(23 downto 20), output => HEX5);
	
	pll5mhz_impl : pll5mhz port map(
		areset => '0',
		inclk0 => ADC_CLK_10,
		c0 => clk_5mhz,
		locked => locked_5mhz
	);
	
	pll12_5mhz_impl : pll12_5mhz port map(
		areset => '0',
		inclk0 => ADC_CLK_10,
		c0 => clk_12_5mhz,
		locked => locked_12_5mhz
	);
	
	psh_db_impl : debounce port map (clk => clk_5mhz, d_in => key_inverted(0), d_out => psh_db);
	rst_db_impl : debounce port map (clk => clk_5mhz, d_in => key_inverted(1), d_out => rst_db);
	
	fifo_impl : fifo port map (
		aclr => rst_master,
		data => fifo_in,
		rdclk => clk_12_5mhz,
		rdreq => fifo_read,
		wrclk => clk_5mhz,
		wrreq => fifo_write,
		q => fifo_out,
		rdusedw => fifo_read_count,
		wrusedw => open
	);

	-- [DIRECT BEHAVIOR] --
	-- Directly assign the values of the switches to the LEDs
	LEDR <= SW;
	key_inverted <= not KEY(1) & not KEY(0);
	fifo_in <= std_logic_vector(SW);
	
	-- [PROCESSES] --
	-- [BLOCK A] --
	-- Handles the button presses and FIFO writing
	process (clk_5mhz) begin
		if rising_edge(clk_5mhz) then
			a_current_state <= a_next_state;
			case (a_next_state) is
				when A_RST =>
					rst_master <= '1';
					fifo_write <= '0';

				when A_PUSH =>
					rst_master <= '0';
					fifo_write <= '1';

				when others =>
					rst_master <= '0';
					fifo_write <= '0';
					
		 end case;
		end if;
	end process;
	
	process (a_current_state, psh_db, rst_db) begin
		case (a_current_state) is
			when A_IDLE =>
			  if rst_db = '1' then a_next_state <= A_RST;
			  elsif psh_db = '1' then a_next_state <= A_PUSH;
			  else a_next_state <= A_IDLE; end if;

			when A_RST =>
			  if rst_db = '1' then a_next_state <= A_HOLD;
			  else a_next_state <= A_IDLE; end if;

			when A_PUSH=>
			  if psh_db = '1' then a_next_state <= A_HOLD;
			  else a_next_state <= A_IDLE; end if;

			when A_HOLD =>
			  if psh_db = '1' or rst_db = '1' then a_next_state <= A_HOLD;
			  else a_next_state <= A_IDLE; end if;

			when others => a_next_state <= A_IDLE;
	 end case;
end process;
	
	-- [BLOCK B] --
	-- Handles FIFO reading and the accumulator
	process (clk_12_5mhz) begin
		if rising_edge(clk_12_5mhz) then
			b_current_state <= b_next_state;
			case (b_next_state) is
				when B_IDLE =>
					fifo_read <= '0';
					count <= count;
				
				when B_PULL =>
					fifo_read <= '1';
					count <= count + unsigned(fifo_out);
				
				when B_RST =>
					fifo_read <= '0';
					count <= (others => '0');
				
				when others =>
					fifo_read <= '0';
					count <= count;
					
			end case;
		end if;
	end process;
	
	process (b_current_state, fifo_read_count, rst_master) begin
		case (b_current_state) is
			when B_IDLE =>
				if fifo_read_count = "101" then b_next_state <= B_PULL;
				elsif rst_master = '1' then b_next_state <= B_RST;
				else b_next_state <= B_IDLE; end if;
				
			when B_PULL =>
				if fifo_read_count = "000" then b_next_state <= B_IDLE;
				else b_next_state <= B_PULL; end if;
			
			when B_RST =>
				if rst_master = '1' then b_next_state <= B_RST;
				else b_next_state <= B_IDLE; end if;
			
			when others => b_next_state <= B_IDLE;
		end case;
	end process;
	
end architecture behavioral;