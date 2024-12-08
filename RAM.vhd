library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity RAM is
	Port(
		RAM_IN: in std_logic_vector(7 downto 0); 	--wejscie
		RAM_OUT: out std_logic_vector(7 downto 0); 	--wyjscie
		RAM_WR: in std_logic; 								--Zezwolenie
		RAM_CLOCK: in std_logic;							--zegar
		RAM_ms: in std_logic_vector(1 downto 0) 		--rej. RAR (clk, clr)
	);
end RAM;

architecture Behavioral of RAM is
-------------------------------------------------------------------------------------------
	attribute RAM_style: string;															--typ pamiêci
	type RAM_ARRAY is array (0 to 255 ) of std_logic_vector (7 downto 0); 	--definicja rozmiaru 
																									--pamiêci RAM 2^8=128, 8 bit wejœcie/wyjœcie
	signal RAM: RAM_ARRAY; 	
	signal RAM_ADDR : std_logic_vector(7 downto 0);		--adres ram
-------------------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------------------
	process(RAM_CLOCK,RAM_WR)												--proces zegarowy
		begin
			if(rising_edge(RAM_CLOCK)) then								--je¿eli narastaj¹ce zbocze zegara
					
				if(RAM_WR='1') then 											--je¿eli RAM_WR=1
					
					RAM(to_integer(unsigned(RAM_ADDR))) <= RAM_IN; 	--przypisz do pojedynczej komórki pamiêci zgodnie z
																					--adresem zawartoœæ odczytan¹
				end if;
			RAM_OUT <= RAM(to_integer(unsigned(RAM_ADDR)));			--przypisanie wyjscia
			end if;
	end process;
---------------------------------------------------------------------------------------------
	process(RAM_ms(1), RAM_ms(0))				--rejestr RAR
		begin
			if(rising_edge(RAM_ms(1))) then	--zapis
				if (RAM_ms(0)='0') then
					RAM_ADDR<=RAM_IN;
				end if;
			end if;
			
			if(RAM_ms(0)='1') then				--zerowanie
				RAM_ADDR<="00000000";
			end if;
	end process;
	
end Behavioral;

