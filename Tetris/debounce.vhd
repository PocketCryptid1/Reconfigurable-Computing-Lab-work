library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
	port(
		-- [INPUTS] --
		clk 	: in std_logic;	-- The clock that drives the state machine
		d_in 	: in std_logic;	-- The value to debounce
		
		-- [OUTPUTS] --
		d_out : out std_logic	-- The debounced value
	);
end entity debounce;

architecture behavioral of debounce is
	-- [SIGNALS & CONSTANTS] --
	signal current_state : std_logic_vector(1 downto 0) := "00";
	signal next_state		: std_logic_vector(1 downto 0) := "00";
	
	constant IDLE 			: std_logic_vector(1 downto 0) := "00";
	constant PUSH_DOWN 	: std_logic_vector(1 downto 0) := "01";
	constant HOLD 			: std_logic_vector(1 downto 0) := "10";
	constant PULL_UP 		: std_logic_vector(1 downto 0) := "11";
begin

	-- [PROCESSES] --
	process (clk)
	begin
		if rising_edge(clk) then
			current_state <= next_state;
			case (next_state) is
				when PULL_UP => d_out <= '1';
				when others => d_out <= '0';
			end case;
		end if;
	
	end process;
	
	process (current_state, d_in)
	begin
		case (current_state) is
			when IDLE =>
				-- If the button is zero, then idle.
				-- If the button is one, then start debouncing to 1
				if d_in = '0' then next_state <= IDLE;
				else next_state <= PUSH_DOWN; end if;
			
			when PUSH_DOWN =>
				-- If the button is zero again, then go back to IDLE
				-- If the button is two again, then HOLD that value
				if d_in = '0' then next_state <= IDLE;
				else next_state <= HOLD; end if;
				
			when HOLD =>
				-- If the button is zero, begin debouncing to 0
				-- If the button is one, then HOLD that value
				if d_in = '0' then next_state <= PULL_UP;
				else next_state <= HOLD; end if;
				
			when PULL_UP =>
				-- If the button is zero, then go back to IDLE
				-- If the button is one again, then HOLD that value
				if d_in = '0' then next_state <= IDLE;
				else next_state <= HOLD; end if;
		
			when others => next_state <= IDLE;
		end case;
	
	end process;


end architecture behavioral;
