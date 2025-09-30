library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LFSR_tb is
end LFSR_tb;

architecture behavioral of LFSR_tb is
    -- instatiate LFSR
   	component lfsr_8bit
		port(
			clk : in std_logic;
			rst_l : in std_logic;
			enabled : in std_logic;
			seed : in std_logic_vector(7 downto 0);
			result: out std_logic_vector(7 downto 0)
		);
	end component lfsr_8bit;

    signal clk      : std_logic := '0';
    signal rst_l    : std_logic := '0';
    signal enabled  : std_logic := '1';   --active low
    signal seed     : std_logic_vector(7 downto 0) := "10000001";
    signal result   : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 30 ns;

begin
    uut: lfsr_8bit port map(
        clk => clk,
        rst_l => rst_l,
        enabled => enabled,
        seed => seed,
        result => result
    );

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process;

    key_process : process
    begin
        rst_l <= '0';
        wait for clk_period * 10;
        rst_l <= '1';
        wait for clk_period * 10;
        enabled <= '0';
        wait;
    end process;
end architecture behavioral;
