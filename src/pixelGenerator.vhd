-- VGA_controller pixel generator module
-- pixel signal generator for VGA_controller
-- Maxime Chretien (MixLeNain)
-- v1.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pixelGen is
	generic(
		constant H_SYNC_value : integer_vector(0 to 3) := (800, 40, 128, 88); -- 800x600 @ 60Hz (cf: VGA standards)
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
end pixelGen;

architecture pixelGen of pixelGen is
	signal addr : std_logic_vector(12 downto 0);
	signal data : std_logic_vector(7 downto 0);
begin
	
	process begin
		wait until rising_edge(clk);
		-- When it's time to display pixels, diplay them 10 time to convert 80x60 picture to 800x600 screen
		if(Vsync_count <= V_SYNC_value(0) and Hsync_count <= H_SYNC_value(0)) then
			addr <= std_logic_vector(to_unsigned(((Vsync_count/10)*(H_SYNC_value(0)/10))+Hsync_count/10,addr'length)); -- rom address
			data <= dataIn;
		else -- When it's not time to display pixels (back porch, sync pulse, front porch)
			addr <= (others => '0');
			data <= (others => '0');
		end if;
	end process;
	
	-- Transmit address to rom component
	address <= addr;
	
	-- Output data bits to correponding output
	R(2) <= data(7);
	R(1) <= data(6);
	R(0) <= data(5);
	G(2) <= data(4);
	G(1) <= data(3);
	G(0) <= data(2);
	B(1) <= data(1);
	B(0) <= data(0);

end pixelGen;