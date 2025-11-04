library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
	port (
		-- [INPUTS] --
		clk 		: in std_logic;								-- clock input
		pixel		: in std_logic_vector(11 downto 0);			-- the async pixel value
		
		-- [OUTPUTS]--
		vga_r 	: out std_logic_vector(3 downto 0);				-- r pixel value
		vga_b	: out std_logic_vector(3 downto 0);				-- b pixel value
		vga_g	: out std_logic_vector(3 downto 0);				-- g pixel value
		vga_hs	: out std_logic;								-- HS controller
		vga_vs	: out std_logic;								-- VS controller
		x_coord : out integer range 0 to 639;				-- current x coordinate (0-639)
		y_coord : out integer range 0 to 479				-- current y coordinate (0-479)
	);
end entity vga;

architecture behavioral of vga is
	-- [SIGNALS] --
	signal h_count : integer range 0 to 800 := 0;  -- Horizontal counter
	signal v_count : integer range 0 to 525 := 0;  -- Vertical counter
	signal pixel_clk : std_logic := '0';          -- 25MHz pixel clock
	signal pixel_enable : std_logic := '0';       -- Active display area enable
	
	-- [CONSTANTS] --
	-- Horizontal timing (pixels)
	constant H_DISPLAY   : integer := 640;   -- Display width
	constant H_FRONT     : integer := 16;    -- Front porch
	constant H_SYNC      : integer := 96;    -- Sync pulse
	constant H_BACK      : integer := 48;    -- Back porch
	constant H_TOTAL     : integer := 800;   -- Total horizontal pixels
	
	-- Vertical timing (lines)
	constant V_DISPLAY    : integer := 480;  -- Display height
	constant V_FRONT     : integer := 10;    -- Front porch
	constant V_SYNC      : integer := 2;     -- Sync pulse
	constant V_BACK      : integer := 33;    -- Back porch
	constant V_TOTAL     : integer := 525;   -- Total vertical lines

begin
	-- [DIRECT CONNECTIONS] --
	-- Map RGB values when in active display area
	vga_r <= pixel(11 downto 8) when pixel_enable = '1' else "0000";
	vga_g <= pixel(7 downto 4)  when pixel_enable = '1' else "0000";
	vga_b <= pixel(3 downto 0)  when pixel_enable = '1' else "0000";
	
	-- Output current coordinates when in active display area
	x_coord <= h_count when pixel_enable = '1' else 0;
	y_coord <= v_count when pixel_enable = '1' else 0;

	-- [PROCESSES] --
	-- Generate 25MHz pixel clock from 50MHz input clock
	process(clk)
	begin
		if rising_edge(clk) then
			pixel_clk <= not pixel_clk;
		end if;
	end process;

	-- Horizontal and vertical counters
	process(clk)
	begin
		if rising_edge(clk) and pixel_clk = '1' then
			-- Horizontal counter
			if h_count = H_TOTAL - 1 then
				h_count <= 0;
				-- Vertical counter
				if v_count = V_TOTAL - 1 then
					v_count <= 0;
				else
					v_count <= v_count + 1;
				end if;
			else
				h_count <= h_count + 1;
			end if;
		end if;
	end process;

	-- Generate sync signals and pixel enable
	process(clk)
	begin
		if rising_edge(clk) and pixel_clk = '1' then
			-- Horizontal sync
			if h_count < (H_DISPLAY + H_FRONT) or 
			   h_count >= (H_DISPLAY + H_FRONT + H_SYNC) then
				vga_hs <= '1';
			else
				vga_hs <= '0';
			end if;

			-- Vertical sync
			if v_count < (V_DISPLAY + V_FRONT) or 
			   v_count >= (V_DISPLAY + V_FRONT + V_SYNC) then
				vga_vs <= '1';
			else
				vga_vs <= '0';
			end if;

			-- Pixel enable (active display area)
			if h_count < H_DISPLAY and v_count < V_DISPLAY then
				pixel_enable <= '1';
			else
				pixel_enable <= '0';
			end if;
		end if;
	end process;
end architecture behavioral;