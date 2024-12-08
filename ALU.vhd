library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

entity ALU is
	generic ( 
     constant N: natural := 1  
    );
	 
	port(
		A, B : in std_logic_vector(7 downto 0);	--wejscia
		S : in std_logic_vector(4 downto 0);		--wejscie sterujace
		Y : out std_logic_vector(7 downto 0);		--wyjscie
		STS : out std_logic_vector(3 downto 0)		--Cout, A=B, A>B, A<B
		);	

end ALU;

architecture Behavioral of ALU is

	signal ALU_out : std_logic_vector(7 downto 0);	--wyjscie alu
	signal STS_out : std_logic_vector(3 downto 0);	--wyjscie sts
	signal tmp : std_logic_vector(8 downto 0);		--zmienna do przeniesienia

begin
---------------------------------------------------------------	
	process(A,B,S)												--ALU
		begin
			case(S) is
				when "00000" => ALU_out <= A;
				when "00001" => ALU_out <= A+1;
				when "00010" => ALU_out <= A+B;
				when "00011" => ALU_out <= A-B;
				when "00100" => ALU_out <= A and B;
				when "00101" => ALU_out <= A or B;
				when "00110" => ALU_out <= A xor B;
				when "00111" => ALU_out <= A nand B;
				when "01000" => ALU_out <= A nor B;
				when "01001" => ALU_out <= A xnor B;
				when "01010" => ALU_out <= not A;
				when "01011" => ALU_out <= std_logic_vector(unsigned(A) sll N);--przesuniecie w lewo
				when "01100" => ALU_out <= std_logic_vector(unsigned(A) srl N);--przesuniecie w prawo
				when "01101" => ALU_out <= std_logic_vector(unsigned(A) rol N);--rotacja w lewo
				when "01110" => ALU_out <= std_logic_vector(unsigned(A) ror N);--rotacja w prawo
				when "01111" => ALU_out <= A-1;
				when "10000" => ALU_out <= A+B+1;
				when "10001" => ALU_out <= B;
				when others => ALU_out <= A;
			end case;
	end process;
----------------------------------------------------------------
	process(A,B)									--komparator
		begin
			if(A=B) then
				STS_out(2)<= '1';
			end if;  
			if(A>B) then
				STS_out(1)<= '1';
			end if;
			if(A<B) then
				STS_out(0)<= '1';
			end if;
	end process;
----------------------------------------------------------------	
	tmp <= ('0' & A) + ('0' & B);	--wyjscie przeniesienia
	STS_out(3) <= tmp(8); 

	Y<=ALU_out;		--przypisanie do wyjsc
	STS<=STS_out;
	
end Behavioral;

