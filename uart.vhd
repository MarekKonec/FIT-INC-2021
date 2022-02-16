-- uart.vhd: UART controller - receiving part
-- Author:  Vojtech Orava (xorava02)
-- INC 2021 projekt
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_RX is
generic (
	  init_val : std_logic := '0'
 );
port(	
   CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0) := (others => init_val);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal cnt : std_logic_vector(4 downto 0);
signal rx_en : std_logic;
signal cnt_en : std_logic;
signal DATA_VALID : std_logic;
begin
	FSM: entity work.UART_FSM(behavioral)
	port map(
		CLK 	=> CLK,
		RST	=> RST,
		DIN 	=> DIN,
		CNT 	=> cnt,		
		RX_EN => rx_en,
		CNT_EN => cnt_en,
		DOUT_VLD => DATA_VALID
	);	
	DOUT_VLD <= DATA_VALID;
	process (CLK) 
	variable cnt2 : integer := 0;
	begin
		if rising_edge(CLK) then		
			if cnt_en = '1' then
				cnt <= cnt + 1;
			else
				cnt <= "00000";
			end if;
			
			if DATA_VALID = '1' then				
				cnt2 := 0;
			end if;
			
			if rx_en = '1' and cnt(4) = '1' then --po 16 nabeznych hranach vypisujeme cislo											
				cnt <= "00000";
				DOUT(cnt2) <= DIN;
				cnt2 := cnt2 + 1;					
			end if;
		end if;
	end process;
end behavioral;
