library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DCE_Q818 is
	Port(
		CPU_in : in std_logic;
		CPU_out1 : out std_logic;
		CPU_out2 : out std_logic_vector(7 downto 0);
		--CPU_romd : in std_logic_vector(12 downto 0);
		--CPU_roma : out std_logic_vector(10 downto 0);
		CPU_reset : in std_logic;
		CPU_clock : in std_logic
	);
end DCE_Q818;

architecture Behavioral of DCE_Q818 is
	
	component CORE_MS2												
		Port(
		MS2_IN : in std_logic_vector(7 downto 0);		--wejscie danych z I/O
		MS2_DB : in std_logic_vector(7 downto 0);		--wejscie danych z LOGIC
		MS2_RAM : in std_logic_vector(7 downto 0);	--wejscie danych z RAM
		MS2_ms : in std_logic_vector(9 downto 0);		--sygnal sterujacy MUX1 MUX0 CLR (A, B, C, STS) CLK (A, B, C, STS)
		MS2_OUT : out std_logic_vector(7 downto 0);	--wyjscie danych
		MS2_STS : out std_logic_vector(3 downto 0)	--wyjscie rejestru STS
		);
	end component;
	
	component I_O
		Port(
		IO_in : in std_logic;		--we zewnetrzne
		IO_bus : in std_logic_vector(7 downto 0);		--we z magistrali
		IO_out1 : out std_logic_vector(7 downto 0);	--wy rej. IN
		IO_out2 : out std_logic;	--wy ogolne1
		IO_out3 : out std_logic_vector(7 downto 0);	--wy odolne2
		IO_ms : in std_logic_vector(4 downto 0);		--CLK (IN, OUT1, OUT2), CLR
		IO_clk : in std_logic
		);
	end component;
	
	component LOGIC
		Port(
		Logic_romd : in std_logic_vector(12 downto 0);	--wejscie z rom
		Logic_roma : out std_logic_vector(10 downto 0);	--adres dla rom
		Logic_ms : out std_logic_vector(20 downto 0);	--magistrala sterujaca
		Logic_clk : in std_logic;								--zegar	
		Logic_reset : in std_logic;							--reset
		Logic_sts : in std_logic_vector(3 downto 0);		--wejscie z sts
		Logic_bus : in std_logic_vector(7 downto 0);		--wejscie z CORE_MS2
		Logic_db : out std_logic_vector(7 downto 0)		--wyjscie dane bezp.
		);
	end component;
	
	component RAM
		Port(
		RAM_IN: in std_logic_vector(7 downto 0); 		--wejscie
		RAM_OUT: out std_logic_vector(7 downto 0); 	--wyjscie
		RAM_WR: in std_logic; 								--Zezwolenie
		RAM_CLOCK: in std_logic;							--zegar
		RAM_ms: in std_logic_vector(1 downto 0) 		--rej. RAR (clk, clr)
		);
	end component;
	
	component ROM
		port(
		ROM_ADDR: in std_logic_vector(10 downto 0); 		--Adres
		ROM_CLOCK: in std_logic;								--zegar
		ROM_DATA_OUT: out std_logic_vector(12 downto 0) --Dane wyjœciowe
		);
	end component;
	
	signal clock : std_logic;
	signal S1 : std_logic_vector(7 downto 0);
	signal S2 : std_logic_vector(7 downto 0);
	signal S3 : std_logic_vector(7 downto 0);
	signal m_s : std_logic_vector(20 downto 0);
	signal bus1 : std_logic_vector(7 downto 0);
	signal S4 : std_logic_vector(3 downto 0);
	signal S5 : std_logic_vector(7 downto 0);
	signal CPU_reset1 : std_logic;
	signal clock1 : std_logic_vector(21 downto 0);
	signal clock_o : std_logic;
	signal data : std_logic_vector(12 downto 0);
	signal addr : std_logic_vector(10 downto 0);
	signal ios : std_logic_vector(4 downto 0);
begin
	
	U1 : CORE_MS2														--przypisanie pinow
		Port map(
			MS2_IN => S1,
			MS2_DB => S2,
			MS2_RAM => S3,
			MS2_ms => m_s(9 downto 0),
			MS2_OUT => bus1,
			MS2_STS => S4
		);
		
	U2 : I_O
		Port map(
			IO_in => CPU_in,
			IO_bus => bus1,
			IO_out1 => S1,
			IO_out2 => CPU_out1,
			IO_out3 => CPU_out2,
			IO_ms => ios,
			IO_clk => CPU_clock
		);
		ios(3 downto 0)<= m_s(13 downto 10);
		ios(4)<= m_s(20);
	U3 : LOGIC
		Port map(
			Logic_romd => data,
			Logic_roma => addr,
			Logic_ms => m_s,
			Logic_clk => clock_o,
			Logic_reset => CPU_reset1,
			Logic_sts => S4,
			Logic_bus => bus1,
			Logic_db => S2 
		);
		
	U4 : RAM
		Port map(
			RAM_IN => bus1,
			RAM_OUT => S3,
			RAM_WR => m_s(14),
			RAM_CLOCK => m_s(15),
			RAM_ms => m_s(17 downto 16)
		);
		
	U5 : ROM
	port map(
		ROM_ADDR=>addr,
		ROM_CLOCK=>CPU_clock,
		ROM_DATA_OUT=>data
	);
--------------------------------------------------------		
	process(CPU_clock)
		begin
			if rising_edge(CPU_clock) then
				clock1<=clock1 +1;
			end if;
	end process;
--------------------------------------------------------

	with S5 select
		clock_o<=clock1(21) when "00000000",	--2,8Hz
					clock1(20) when "00000001",	--5,7Hz
					clock1(19) when "00000010",	--11Hz
					clock1(18) when "00000011",	--22Hz
					clock1(17) when "00000100",	--45Hz
					clock1(16) when "00000101",	--91Hz
					clock1(15) when "00000110",	--183Hz
					clock1(14) when "00000111",	--366Hz
					clock1(13) when "00001000",	--732Hz
					clock1(12) when "00001001",	--1,5kHz
					clock1(11) when "00001010",	--3kHz
					clock1(10) when "00001011",	--5kHz
					clock1(9) when "00001100",		--11kHz
					clock1(8) when "00001101",		--23kHz
					clock1(7) when "00001110",		--46kHz
					clock1(6) when "00001111",		--93kHz
					clock1(5) when "00010000",		--187kHz
					clock1(4) when "00010001",		--375kHz
					clock1(3) when "00010010",		--750kHz
					clock1(2) when "00010011",		--1,5MHz
					clock1(1) when "00010100",		--3MHz
					clock1(0) when "00010101",		--6MHz
					CPU_clock when "00010110",		--12MHz
				   clock1(21) when others;			--2,8Hz
---------------------------------------------------					
	process(m_s(18), m_s(19))								--rejestr takt.
		begin
			if rising_edge(m_s(18)) then
				S5<=S2;
		   end if;
			
			if m_s(19)='1' then
				S5<="00000000";
			end if;
	end process;
---------------------------------------------------	
	CPU_reset1<= not(CPU_reset);
	
end Behavioral;

