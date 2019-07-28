-- VGA_controller
-- A simple VGA_controller that output 8 bits colors (RRRGGGBB)
-- Maxime Chretien (MixLeNain)
-- v1.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vhdl_parts.all;

entity VGA_controller is
	generic(
		constant F_clk	 : integer := 50000000; --50 MHz - Clock Frequency
		constant H_SYNC : integer_vector(0 to 3) := (800, 40, 128, 88); -- 800x600 @ 60Hz
		constant V_SYNC : integer_vector(0 to 3) := (600, 1, 4, 23)
	);
	port(
		clk		: in 	std_logic; -- Input clock
		--VGA Signals
		VGA_HSync: out std_logic;
		VGA_VSync: out std_logic;
		VGA_R		: out std_logic_vector(2 downto 0);
		VGA_G		: out std_logic_vector(2 downto 0);
		VGA_B		: out std_logic_vector(1 downto 0)
	);
end VGA_controller;

architecture VGA_controller of VGA_controller is
	-- Component declarations
	component pll is 
		PORT
		(
			inclk0: IN  STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC 
		);
	END component;
	
	component sync is
		generic(
			constant H_SYNC_value : integer_vector(0 to 3) := (800, 40, 128, 88); -- 800x600 @ 60Hz (cf: VGA standards)
			constant V_SYNC_value : integer_vector(0 to 3) := (600, 1, 4, 23)
		);
		port(
			clk			: in  std_logic;
			Vsync			: out std_logic 	:= '1';
			Hsync			: out std_logic 	:= '1';
			Vsync_count	: out natural 		:= 0;
			Hsync_count	: out natural 		:= 0
		);
	end component;
	
	component pixelGen is
		generic(
			constant H_SYNC_value : integer_vector(0 to 3) := (800, 40, 128, 88); -- 800x600 @ 60Hz
			constant V_SYNC_value : integer_vector(0 to 3) := (600, 1, 4, 23)
		);
		port(
			clk 			: in 	std_logic;
			Vsync_count	: in 	natural;
			Hsync_count	: in 	natural;
			dataIn		: in 	std_logic_vector(7 downto 0);
			address		: out std_logic_vector(12 downto 0) := (others => '0');
			R				: out std_logic_vector(2 downto 0);
			G				: out std_logic_vector(2 downto 0);
			B				: out std_logic_vector(1 downto 0)
		);
	end component;
	
	-- Signals to connect different components
	signal pixel_clk	: std_logic := '0'; --40 MHz
	signal V_count		: natural;
	signal H_count		: natural;
	signal data			: std_logic_vector(7 downto 0);
	signal addr			: std_logic_vector(12 downto 0) := (others => '0');
begin
	-- 40 MHz clock generation
	clk40MHz : pll port map(inclk0 => clk, c0 => pixel_clk);
	
	-- VGA HSYNC and VSYNC generation
	VGAsync: sync
		generic map(H_SYNC_value => H_SYNC, V_SYNC_value => V_SYNC)
		port map(clk => pixel_clk, Vsync => VGA_VSync, Hsync => VGA_HSync, Vsync_count => V_count, Hsync_count => H_count);
	
	-- ROM containing image pixels
	Img: rom
		generic map(addressBits => 13, dataBits => 8, init_file => "image.mif")
		port map(clk => pixel_clk, address => addr, dataOut => data, nOutputEnable => '0');
		
	-- Pixel color generation
	pixGen: pixelGen
		generic map(H_SYNC_value => H_SYNC, V_SYNC_value => V_SYNC)
		port map(clk => pixel_clk, address => addr, dataIn => data, Vsync_count => V_count, Hsync_count => H_count, R => VGA_R, G => VGA_G, B => VGA_B);

end VGA_controller;