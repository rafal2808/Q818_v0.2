library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------------------------------

entity CORE_MS2 is
	Port(
		MS2_IN : in std_logic_vector(7 downto 0);		--wejscie danych z I/O
		MS2_DB : in std_logic_vector(7 downto 0);		--wejscie danych z LOGIC
		MS2_RAM : in std_logic_vector(7 downto 0);	--wejscie danych z RAM
		MS2_ms : in std_logic_vector(9 downto 0);		--sygnal sterujacy MUX1 MUX0 CLR (A, B, C, STS) CLK (A, B, C, STS)
		MS2_OUT : out std_logic_vector(7 downto 0);	--wyjscie danych
		MS2_STS : out std_logic_vector(3 downto 0)	--wyjscie rejestru STS
		);
		
end CORE_MS2;

------------------------------------------------------------------------------------------------------

architecture Behavioral of CORE_MS2 is

	signal Aout : std_logic_vector(7 downto 0);		--wyjscie rejestru A
	signal Bout : std_logic_vector(7 downto 0);		--wyjscie rejestru B
	signal Cout : std_logic_vector(4 downto 0);		--wyjscie rejestru C
	signal STSout : std_logic_vector(3 downto 0);	--wyjscie rejestru STS
	signal ADDR : std_logic_vector(1 downto 0);		--adres multipleksera
	signal MUXout : std_logic_vector(7 downto 0);	--wyjscie multipleksera
	signal bus_out : std_logic_vector(7 downto 0);	--wyjscie core
--------------------------------------------------------------------------------

	component ALU												--deklaracja ALU
		Port(
		A, B : in std_logic_vector(7 downto 0);
		S : in std_logic_vector(4 downto 0);
		Y : out std_logic_vector(7 downto 0);
		STS : out std_logic_vector(3 downto 0)
		);
	end component;
--------------------------------------------------------------------------------
begin
	
	U1 : ALU														--przypisanie pinow
		Port map(
			A => Aout,
			B => Bout,
			S => Cout,
			Y => bus_out,
			STS => STSout
		);
	
----------------------------------------------------------------------------	
	ADDR<= MS2_ms(9 downto 8);						--multiplekser przypisanie

	with ADDR select						
		MUXout<= MS2_IN when "00",			--sygnal wybierany		
					MS2_DB when "01",			--zgodnie z adresem
					MS2_RAM when "10",
					bus_out when others;
					
----------------------------------------------------------------------------					
	process(MS2_ms(3), MS2_ms(7))								--rejestr A
		begin
			if rising_edge(MS2_ms(3)) then					--zapis
				if MS2_ms(7)='0' then	
					Aout<= MUXout;
				end if;
			end if;
			
			if MS2_ms(7)='1' then								--reset
				Aout<= "00000000";
			end if;
	end process;	
------------------------------------------------------------------------------
	process(MS2_ms(2), MS2_ms(6))								--rejestr B
		begin
			if rising_edge(MS2_ms(2)) then					--zapis
				if MS2_ms(6)='0' then	
					Bout<= Aout;
				end if;
			end if;
			
			if MS2_ms(6)='1' then								--reset
				Bout<= "00000000";
			end if;
	end process;

------------------------------------------------------------------------------
	process(MS2_ms(1), MS2_ms(5))							--rejestr C
		begin
			if rising_edge(MS2_ms(1)) then				--zapis
				if MS2_ms(5)='0' then	
					Cout<=Aout(4 downto 0);
				end if;
			end if;
			
			if MS2_ms(5)='1' then							--reset
				Cout<= "00000";
			end if;
	end process;	
--------------------------------------------------------------------------------
	process(MS2_ms(0), MS2_ms(4))								--rejestr STS
		begin
			if rising_edge(MS2_ms(0)) then					--zapis
				if MS2_ms(4)='0' then	
					MS2_STS<= STSout;
				end if;
			end if;
			
			if MS2_ms(4)='1' then								--reset
				MS2_STS<= "0000";
			end if;	
	end process;	
--------------------------------------------------------------------------------	
	MS2_OUT<= bus_out;		--przypisanie wyjscia

end Behavioral;

