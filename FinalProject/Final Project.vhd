library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity final_project is
    port(
        clk     : in std_logic;
		key     : in std_logic_vector(1 downto 0);

        vga_r 	: out std_logic_vector(3 downto 0);
		vga_b	: out std_logic_vector(3 downto 0);
		vga_g	: out std_logic_vector(3 downto 0);
		vga_hs	: out std_logic;
		vga_vs	: out std_logic;

        arduino_io : inout std_logic_vector(15 downto 0);
        arduino_reset_n : inout std_logic
    );
end entity final_project;

architecture behavioral of final_project is

    --[COMPONENTS]--

    --[SIGNALS]--

    --[CONSTANTS]--

begin

end architecture behavioral;