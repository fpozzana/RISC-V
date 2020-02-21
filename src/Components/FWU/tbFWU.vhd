library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.define.all;

entity TB_FWU is
end TB_FWU;

architecture TEST of TB_FWU is

	signal	rsoneIn, rstwoIn, rdaluIn, rdmemIn : std_logic_vector(4 downto 0) := "00000";
	signal	AluForwardingOneOut, AluForwardingTwoOut, MemForwardingOneOut, MemForwardingTwoOut : std_logic;
	signal opcode : std_logic_vector(6 downto 0);

	component FWU
  port (opcode : IN std_logic_vector(6 downto 0);
				rsoneIn : IN std_logic_vector(4 downto 0);
        rstwoIn : IN std_logic_vector(4 downto 0);
        rdaluIn : IN std_logic_vector(4 downto 0);
        rdmemIn : IN std_logic_vector(4 downto 0);
        AluForwardingOneOut : OUT std_logic;
        MemForwardingOneOut : OUT std_logic;
        AluForwardingTwoOut : OUT std_logic;
        MemForwardingTwoOut : OUT std_logic);
	end component;

begin

	U1 : FWU
	port map(opcode, rsoneIn, rstwoIn, rdaluIn, rdmemIn, AluForwardingOneOut, MemForwardingOneOut, AluForwardingTwoOut, MemForwardingTwoOut);

  rstwoIn <= "00001" after 12 ns;
  rdaluIn <= "00001" after 10 ns;
  rdmemIn <= "00001" after 15 ns;
	opcode <= R_TYPE, "1111111" after 25 ns;

end TEST;

configuration CFG_TB_FWU of TB_FWU is
   for TEST
      for U1: FWU
         use configuration WORK.CFG_FWU_BEHAVIORAL;
      end for;
   end for;
end CFG_TB_FWU;
