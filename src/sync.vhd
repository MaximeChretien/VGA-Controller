-- VGA_controller sync module
-- H_sync and V_sync generator for VGA_controller
-- Maxime Chretien (MixLeNain)
-- v1.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync is
	generic(
		constant H_SYNC_value : integer_vector(0 to 3) := (800, 40, 128, 88); -- 800x600 @ 60Hz (cf: VGA standards)
		constant V_SYNC_value : integer_vector(0 to 3) := (600, 1, 4, 23)
	);
	port(
		clk			: in  std_logic;
		Vsync			: out std_logic := '1';
		Hsync			: out std_logic := '1';
		Vsync_count	: out natural;
		Hsync_count	: out natural
	);
end sync;

architecture sync of sync is
	signal V_count: natural := 0;
	signal H_count: natural := 0;
begin
	-- Count HSYNC and VSYNC value
	process 
		variable countH: natural := 0;
		variable countV: natural := 0;
	begin
		wait until rising_edge(clk);
		countH := countH + 1;
		if(countH >= H_SYNC_value(0)+H_SYNC_value(1)+H_SYNC_value(2)+H_SYNC_value(3)) then -- End of a line
			countH := 0;
			countV := countV + 1;
			if(countV >= V_SYNC_value(0)+V_SYNC_value(1)+V_SYNC_value(2)+V_SYNC_value(3)) then -- End of the display
				countV := 0;
			end if;
		end if;
		H_count <= countH;
		V_count <= countV;
	end process;
	
	-- Transmit count value to other components
	Vsync_count <= V_count;
	Hsync_count <= H_count;
	
	-- Output signal state for HSYNC and VSYNC
	Vsync <= '0' when (V_count >= V_SYNC_value(0)+V_SYNC_value(1) and V_count <= V_SYNC_value(0)+V_SYNC_value(1)+V_SYNC_value(2)) else '1';
	Hsync <= '0' when (H_count >= H_SYNC_value(0)+H_SYNC_value(1) and H_count <= H_SYNC_value(0)+H_SYNC_value(1)+H_SYNC_value(2)) else '1';
	
end sync;