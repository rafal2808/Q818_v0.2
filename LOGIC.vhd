library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LOGIC is
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
end LOGIC;

architecture Behavioral of LOGIC is
	signal PC_REG : std_logic_vector(10 downto 0);	--wejscie rej. PCL i PCH
	signal PC_Lclk : std_logic;							--zegar rej. PCL
	signal PC_Lclr : std_logic;							--reset rej. PCL
	signal PC_Hclk : std_logic;							--zegar rej. PCH
	signal PC_Hclr : std_logic;							--reset rej. PCH
	signal PCclk : std_logic;								--zegar PC
	signal PCclr : std_logic;								--reset PC
	signal PCload : std_logic;								--wpisz do PC
	signal PC_out : std_logic_vector(10 downto 0);	--wyjscie PC
	signal DB_clk : std_logic;								--zegar rej. DB
	signal DB_clr : std_logic;								--reset rej. DB
	signal IR_clk : std_logic;								--zegar rej. IR
	signal IR_clr : std_logic;								--reset rej. IR
	signal IR_out : std_logic_vector(4 downto 0);	--wyjscie rej. IR
	signal IR_decoder : std_logic_vector(23 downto 0);	--wyjscie dekodera rozkazow
	signal counter : std_logic_vector(1 downto 0);	--wyjscie licznika zegarowwego
	signal cou_dec : std_logic_vector(2 downto 0);	--wyjscie dekodera licznika zegarowego

begin
-----------------------------------------------------------	
	process(PC_Lclk, PC_Lclr)						--rejestr PCL
		begin
			if rising_edge(PC_Lclk) then
				if PC_Lclr='0' then
					PC_REG(7 downto 0)<=Logic_bus;
				end if;
			end if;
			
			if PC_Lclr='1' then
				PC_REG(7 downto 0)<="00000000";
			end if;
	end process;
-----------------------------------------------------------
	process(PC_Hclk, PC_Hclr)						--rejestr PCH
		begin	
			if rising_edge(PC_Hclk) then
				if PC_Hclr='0' then
					PC_REG(10 downto 8)<=Logic_bus(2 downto 0);
				end if;
			end if;
			
			if PC_Hclr='1' then
				PC_REG(10 downto 8)<="000";
			end if;
	end process;
----------------------------------------------------------
	process(PCclk, PCclr, PCload, PC_REG)		--licznik
		begin
		if rising_edge(PCclk) then					--wartosc licznika +1
			if PCclr='0' then
				if PCload='0' then
				PC_out<= PC_out + 1;
				end if;
			end if;
		end if;
		
		if PCclr='1' then								--reset licznika
			PC_out<= "00000000000";
		end if;
		
		if PCload='1' then							--zapis wartosci poczatkowej
			if PCclr='0' then
				PC_out<= PC_REG;
			end if;
		end if;
	end process;
	
	Logic_roma<= PC_out;
----------------------------------------------------------
	process(DB_clk, DB_clr)							--rejestr DB
		begin
		if rising_edge(DB_clk) then
			if DB_clr='0' then
				Logic_db<=Logic_romd(12 downto 5);
			end if;
		end if;
		
		if DB_clr='1' then
			Logic_db<="00000000";
		end if;
	end process;
-----------------------------------------------------------
	process(IR_clk, IR_clr)							--rejestr IR
		begin
		if rising_edge(IR_clk) then
			if IR_clr='0' then
				IR_out<=Logic_romd(4 downto 0);
			end if;
		end if;
		
		if IR_clr='1' then
			IR_out<="00000";
		end if;
	end process;
-----------------------------------------------------------
	IR_decoder<=x"000000" when IR_out="00000" else		--dekoder rozkazow
					x"000001" when IR_out="00001" else		--bit 0
					x"000002" when IR_out="00010" else		--1
					x"000004" when IR_out="00011" else		--2
					x"000008" when IR_out="00100" else		--3
					x"000010" when IR_out="00101" else		--4
					x"000020" when IR_out="00110" else		--5
					x"000040" when IR_out="00111" else
					x"000080" when IR_out="01000" else
					x"000100" when IR_out="01001" else
					x"000200" when IR_out="01010" else
					x"000400" when IR_out="01011" else
					x"000800" when IR_out="01100" else
					x"001000" when IR_out="01101" else
					x"002000" when IR_out="01110" else
					x"004000" when IR_out="01111" else
					x"008000" when IR_out="10000" else
					x"010000" when IR_out="10001" else
					x"020000" when IR_out="10010" else
					x"040000" when IR_out="10011" else
					x"080000" when IR_out="10100" else
					x"100000" when IR_out="10101" else
					x"200000" when IR_out="10110" else
					x"400000" when IR_out="10111" else		--22
					x"800000" when IR_out="11000";	--23

------------------------------------------------------------
	process(Logic_clk, Logic_reset)			--licznik zegarowy 
		begin
		if rising_edge(Logic_clk) then
			if Logic_reset='0' then
				counter<= counter +1;
			end if;
		end if;
		
		if Logic_reset='1' then
			counter<="00";
		end if;
	end process;
------------------------------------------------------------
	cou_dec<="001" when counter="00" else	--dekoder licznika zegarowego
				"010" when counter="10" else
				"100" when counter="11";
--------------------------------------------------------------------------------------------------------------------
	Logic_ms(0)<= cou_dec(1);														--clk_STS		CORE MS2
	Logic_ms(1)<= cou_dec(1) and IR_decoder(5);								--clk_C
	Logic_ms(2)<= cou_dec(1) and IR_decoder(4);								--clk_B
	Logic_ms(3)<= cou_dec(1) and (((IR_decoder(0) or IR_decoder(1)) or IR_decoder(2)) or IR_decoder(3));	--clk_A
	Logic_ms(4)<= Logic_reset or IR_decoder(20);								--clr_STS
	Logic_ms(5)<= Logic_reset or IR_decoder(20);								--clr_C
	Logic_ms(6)<= Logic_reset or IR_decoder(20);								--clr_B
	Logic_ms(7)<= Logic_reset or (IR_decoder(20) or IR_decoder(13));	--clr_A
	Logic_ms(8)<= IR_decoder(2) or IR_decoder(0);							--mux0
	Logic_ms(9)<= IR_decoder(3) or IR_decoder(0);							--mux1

	Logic_ms(10)<=	Logic_reset or IR_decoder(20);	--CLR			I/O
	Logic_ms(11)<= cou_dec(1) and IR_decoder(9);		--clk_out2
	Logic_ms(12)<= cou_dec(1) and IR_decoder(8);		--clk_out1
	Logic_ms(13)<= cou_dec(1) and IR_decoder(12);	--clk_in
	Logic_ms(20)<= cou_dec(1) and IR_decoder(22);		--set dv
	
	Logic_ms(14)<=	IR_decoder(7);							--wr			RAM
	Logic_ms(15)<=	Logic_clk;								--clock
	Logic_ms(16)<=	Logic_reset or IR_decoder(20);	--clr_rar
	Logic_ms(17)<=	cou_dec(1) and IR_decoder(6);		--clk_rar
	
	Logic_ms(18)<= cou_dec(1) and IR_decoder(21);
	Logic_ms(19)<= Logic_reset or IR_decoder(20);
	
	PC_Lclk<= cou_dec(1) and IR_decoder(10);			--zegar rej. PCL
	PC_Lclr<= Logic_reset or IR_decoder(20);			--reset rej. PCL
	PC_Hclk<= cou_dec(1) and IR_decoder(11);			--zegar rej. PCH
	PC_Hclr<= Logic_reset or IR_decoder(20);			--reset rej. PCH
	PCclk<= cou_dec(2);										--zegar PC
	PCclr<= Logic_reset or IR_decoder(20);				--reset PC
	PCload<= cou_dec(1) and (((((IR_decoder(14) or	((IR_decoder(15) and Logic_sts(1)))) or ((IR_decoder(16) and Logic_sts(0)))) or ((IR_decoder(17) and Logic_sts(2)))) or	((IR_decoder(18) and Logic_sts(3)))) or ((IR_decoder(19) and (not Logic_sts(3)))));	--wpisz do pc
	DB_clk<= cou_dec(0);										--zegar rej. DB
	DB_clr<=	Logic_reset or IR_decoder(20);			--reset rej. DB
	IR_clk<= cou_dec(0);										--zegar rej. IR
	IR_clr<=	Logic_reset or IR_decoder(20);			--reset ir

end Behavioral;

