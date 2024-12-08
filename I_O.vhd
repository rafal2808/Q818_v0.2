library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity I_O is
	Port(
		IO_in : in std_logic;		--rx
		IO_bus : in std_logic_vector(7 downto 0);		--we z magistrali
		IO_out1 : out std_logic_vector(7 downto 0);	--tx
		IO_out2 : out std_logic;	--tx
		IO_out3 : out std_logic_vector(7 downto 0);	--wy odolne2
		IO_ms : in std_logic_vector(4 downto 0);		--setDV, CLK (IN, OUT1, OUT2), CLR
		IO_clk : in std_logic
		);
end I_O;

architecture Behavioral of I_O is

	component UART_receiver
		port (
			i_Clk       : in  std_logic;
			i_RX_Serial : in  std_logic;
			o_RX_DV     : out std_logic;
			o_RX_Byte   : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component UART_transmitter
		Port(
			i_Clk       : in  std_logic;
			i_TX_DV     : in  std_logic;
			i_TX_Byte   : in  std_logic_vector(7 downto 0);
			o_TX_Active : out std_logic;
			o_TX_Serial : out std_logic;
			o_TX_Done   : out std_logic
		);
	end component;

	signal S1 : std_logic:='1';
	signal data : std_logic_vector(7 downto 0);
	signal out1 : std_logic_vector(7 downto 0);
	signal DV : std_logic;
	signal clr_dv : std_logic;
	signal t_done : std_logic;
	signal data1 : std_logic;
begin

	U1 : UART_receiver
		Port map(
			i_Clk =>IO_clk,
			i_RX_Serial=>IO_in,
			o_RX_DV=>S1,
			o_RX_Byte=>data
		);

	U2 : UART_transmitter
		Port map(
			i_Clk => IO_clk, 
			i_TX_DV => DV,   
			i_TX_Byte => out1, 
			o_TX_Active => open,
			o_TX_Serial => data1,
			o_TX_Done => t_done
		);	

		IO_out2<=data1;		
---------------------------------------------------------------------
	process(IO_ms(3), IO_ms(0))							--rejestr IN
		begin
			if rising_edge(IO_ms(3)) then					--zapis
				if IO_ms(0)='0' then	
					IO_out1<= data;
				end if;
			end if;
			if IO_ms(0)='1' then								--reset
				IO_out1<= "00000000";
			end if;
	end process;
---------------------------------------------------------------------
	process(IO_ms(2), IO_ms(0))							--rejestr OUT1
		begin
			if rising_edge(IO_ms(2)) then					--zapis
				if IO_ms(0)='0' then	
					out1<= IO_bus;
				end if;
			end if;
			if IO_ms(0)='1' then								--reset
				out1<="00000000";
			end if;
	end process;
---------------------------------------------------------------------
	process(IO_ms(1), IO_ms(0))							--rejestr OUT2
		begin
			if rising_edge(IO_ms(1)) then					--zapis
				if IO_ms(0)='0' then	
					IO_out3<= IO_bus;
				end if;
			end if;
			if IO_ms(0)='1' then								--reset
				IO_out3<= "00000000";
			end if;
	end process;
---------------------------------------------------------------------
	process(IO_ms(4), clr_dv)
		begin
			if rising_edge(IO_ms(4)) then
				if clr_dv='0' then
					DV<='1';
				end if;
			end if;
			
			if clr_dv='1' then
				DV<='0';
			end if;
	end process;
	
	clr_dv<=IO_ms(0) or t_done;

end Behavioral;
