library IEEE;
use IEEE.std_logic_1164.all;

entity FD is
	Port (	D :	IN	std_logic;
					CK :	IN	std_logic;
					RESET :	IN	std_logic;
					Q :	OUT	std_logic);
end FD;

architecture SYNC of FD is 								-- flip flop D with syncronous reset
	begin
		PSYNCH : process(CK,RESET)
			begin
	  		if CK'event and CK='1' then 			-- positive edge triggered:
	    		if RESET='0' then 							-- active low reset
	      		Q <= '0';
	    		else
	      		Q <= D; 											-- input is written on output
	    		end if;
	  		end if;
			end process;
end SYNC;


configuration CFG_FD_SYNC of FD is
	for SYNC
	end for;
end CFG_FD_SYNC;
