library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator_tb is
end entity accumulator_tb;

architecture behavioral of accumulator_tb is
    -- instantiate accumulator
    component accumulator
        port(
            ADC_CLK_10  : in std_logic;
            KEY         : in std_logic_vector(1 downto 0);
            SW          : in unsigned(9 downto 0);
            HEX0        : out std_logic_vector(7 downto 0);
            HEX1        : out std_logic_vector(7 downto 0);
            HEX2        : out std_logic_vector(7 downto 0);
            HEX3        : out std_logic_vector(7 downto 0);
            HEX4        : out std_logic_vector(7 downto 0);
            HEX5        : out std_logic_vector(7 downto 0);
            LEDR        : out unsigned(9 downto 0)
        );
    end component accumulator;
	 
    signal ADC_CLK_10  : std_logic := '0';
    signal KEY         : std_logic_vector(1 downto 0) := (others => '1');
    signal SW          : unsigned(9 downto 0) := (others => '0');
    signal HEX0        : std_logic_vector(7 downto 0);
    signal HEX1        : std_logic_vector(7 downto 0);
    signal HEX2        : std_logic_vector(7 downto 0);
    signal HEX3        : std_logic_vector(7 downto 0);
    signal HEX4        : std_logic_vector(7 downto 0);
    signal HEX5        : std_logic_vector(7 downto 0);
    signal LEDR        : unsigned(9 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin
    uut: accumulator port map(
        ADC_CLK_10 => ADC_CLK_10,
        KEY         => KEY,
        SW          => SW,
        HEX0        => HEX0,
        HEX1        => HEX1,
        HEX2        => HEX2,
        HEX3        => HEX3,
        HEX4        => HEX4,
        HEX5        => HEX5,
        LEDR        => LEDR
    ); 

    clk_process : process
    begin
        ADC_CLK_10 <= '0';
        wait for CLK_PERIOD/2;
        ADC_CLK_10 <= '1';
        wait for CLK_PERIOD/2;
    end process clk_process;

    -- Stimulus process: drive switches and button presses
    stim_proc: process
    begin
        -- initialize
        KEY <= (others => '1'); -- buttons are active-low
        SW  <= (others => '0');
        wait for 100 ns;

		  -- first, reset
        wait for 40 ns;
        KEY(1) <= '0'; -- press RST
        wait for 60 ns;
        KEY(1) <= '1';
        wait for 200 ns;
        report "After reset, LEDR = " & integer'image(to_integer(LEDR));
		  
        -- Add 3
        SW <= to_unsigned(3, 10);
        wait for 40 ns;
        KEY(0) <= '0'; -- press ADD
        wait for 60 ns;
        KEY(0) <= '1'; -- release
        wait for 200 ns;
        report "After adding 3, LEDR = " & integer'image(to_integer(LEDR));

        -- Add 5
        SW <= to_unsigned(5, 10);
        wait for 40 ns;
        KEY(0) <= '0';
        wait for 60 ns;
        KEY(0) <= '1';
        wait for 200 ns;
        report "After adding 5, LEDR = " & integer'image(to_integer(LEDR));

        -- Add 512 (check overflow beyond 9 bits)
        SW <= to_unsigned(512, 10);
        wait for 40 ns;
        KEY(0) <= '0';
        wait for 60 ns;
        KEY(0) <= '1';
        wait for 200 ns;
        report "After adding 512, LEDR = " & integer'image(to_integer(LEDR));

        -- Reset
        wait for 40 ns;
        KEY(1) <= '0'; -- press RST
        wait for 60 ns;
        KEY(1) <= '1';
        wait for 200 ns;
        report "After reset, LEDR = " & integer'image(to_integer(LEDR));

        -- End simulation
        wait for 200 ns;
        report "End of simulation" severity failure;
    end process stim_proc;

end architecture behavioral;