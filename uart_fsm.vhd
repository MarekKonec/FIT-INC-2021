-- uart_fsm.vhd: UART controller - finite state machine
-- Author:  Vojtech Orava (xorava02)
--	INC 2021 projekt
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_FSM is
generic (
	  init_val : std_logic := '0'
);
port(
   CLK : in std_logic;
   RST : in std_logic;
	DIN : in std_logic;
	CNT : in std_logic_vector(4 downto 0) := (others => init_val);
	RX_EN : out std_logic;
	CNT_EN : out std_logic;
	DOUT_VLD: out std_logic := '0'
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATE_T is (DATA_VALID, WAIT_START_BIT, WAIT_FIRST_BIT, RX_DATA, WAIT_STOP_BIT); --mozne stavy automatu
signal state : STATE_T := WAIT_START_BIT;
begin
	DOUT_VLD <= '1' when state = DATA_VALID else '0';
	
	CNT_EN <= '1' when state = WAIT_FIRST_BIT or state = RX_DATA else '0';
	
	RX_EN <= '1' when state = RX_DATA else '0';
	
	process (CLK) 
	
	variable a: integer := 0;
	begin
		if rising_edge(CLK) then
			if RST = '1' then --reset
				state <= WAIT_START_BIT;
			else
				case state is
					when WAIT_START_BIT => if DIN = '0' then																		
														state <= WAIT_FIRST_BIT;													
													end if;
					when WAIT_FIRST_BIT =>	if CNT = "10000" then -- 10000 = 16
														state <= RX_DATA;														
													end if;
					when RX_DATA   	   =>  if CNT = "10000" then -- 10000 = 16
														a := a + 1;													
													end if;
													if a = 7 then -- 8bitu nacteno																												
														state <= WAIT_STOP_BIT;			
														a := 0;
													end if;
					when WAIT_STOP_BIT  =>  if DIN = '1' then
														state <= DATA_VALID;
													end if;
					when DATA_VALID 	  => state <= WAIT_START_BIT; --potvrzeni dat
					when others			  => null;
				end case;
			end if;
		end if;
	end process;
end behavioral;
