library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity ROM is
	Port(
		ROM_ADDR: in std_logic_vector(10 downto 0); 		--Adres
		ROM_CLOCK: in std_logic;								--zegar
		ROM_DATA_OUT: out std_logic_vector(12 downto 0) --Dane wyjœciowe
	);
end ROM;
------------------------------------------------------------------------------
architecture Behavioral of ROM is
	
	type ROM_ARRAY is array (0 to 2047 ) of std_logic_vector (12 downto 0); --deklaracja pojemnosci
	
	signal ROM: ROM_ARRAY:= (		--zawartosc pamieci
 "0000000000000",
 "0000001010110",
 
 "0101000001101",
 "0000000000010",
 "0000000001010",
 
 "0001001110110",
 
 others=>"0000000000000"); 
-----------------------------------------------------------------------------	
begin
-----------------------------------------------------------------------------	
	process(ROM_CLOCK)							--synch. przypisanie do wyjscia
		begin
			if(rising_edge(ROM_CLOCK)) then	
					ROM_DATA_OUT <= ROM(to_integer(unsigned(ROM_ADDR)));
				end if;
	end process;

end Behavioral;
