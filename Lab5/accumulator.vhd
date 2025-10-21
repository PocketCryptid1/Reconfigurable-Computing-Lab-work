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
			point: in std_logic;
			count: in unsigned(3 downto 0);
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
	
	-- [SIGNALS & CONSTANTS] --
	signal last_add_value : std_logic := '0';
	signal last_rst_value : std_logic := '0';
	
	signal add_db 	: std_logic;
	signal rst_db 	: std_logic;
	signal count 	: unsigned(23 downto 0);
	
	signal current_state : std_logic_vector(1 downto 0) := "00";
	signal next_state : std_logic_vector(1 downto 0) := "00";
	
	constant IDLE : std_logic_vector(1 downto 0) := "00";
	constant RST : std_logic_vector(1 downto 0) := "01";
	constant ADD : std_logic_vector(1 downto 0) := "10";
	constant HOLD : std_logic_vector(1 downto 0) := "11";
	
begin
	-- [INSTANCES] --
	seg0_impl : seg port map(point => '0',	count => count(3 downto 0), output => HEX0);
	seg1_impl : seg port map(point => '0',	count => count(7 downto 4), output => HEX1);
	seg2_impl : seg port map(point => '0',	count => count(11 downto 8), output => HEX2);
	seg3_impl : seg port map(point => '0',	count => count(15 downto 12), output => HEX3);
	seg4_impl : seg port map(point => '0',	count => count(19 downto 16), output => HEX4);
	seg5_impl : seg port map(point => '0',	count => count(23 downto 20), output => HEX5);
	
	add_db_impl : debounce port map (clk => ADC_CLK_10, d_in => not KEY(0), d_out => add_db);
	rst_db_impl : debounce port map (clk => ADC_CLK_10, d_in => not KEY(1), d_out => rst_db);

	-- [DIRECT BEHAVIOR] --
	-- Directly assign the values of the switches to the LEDs
	LEDR <= SW;
	
	-- [PROCESSES] --
	process (ADC_CLK_10)
	begin
		if rising_edge(ADC_CLK_10) then
			current_state <= next_state;
			case (next_state) is
				when RST => count <= (others => '0');
				when ADD => count <= count + SW;
				when others => count <= count;
			end case;
		end if;
	
	end process;
	
	process (rst_db, add_db)
	begin
		case (current_state) is
			when IDLE =>
				if rst_db = '1' then next_state <= RST;
				elsif add_db = '1' then next_state <= ADD;
				else next_state <= IDLE; end if;
			
			when RST =>
				if rst_db = '1' then next_state <= HOLD;
				else next_state <= IDLE; end if;
				
			when ADD =>
				if add_db = '1' then next_state <= HOLD;
				else next_state <= IDLE; end if;
				
			when HOLD =>
				if add_db = '1' or rst_db = '1' then next_state	<= HOLD;
				else next_state <= IDLE; end if;
		
			when others => next_state <= IDLE;
		end case;
	end process;
end architecture behavioral;