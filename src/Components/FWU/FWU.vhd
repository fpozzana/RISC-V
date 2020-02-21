library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity FWU is
  port (opcode : IN std_logic_vector(6 downto 0);
        rsoneIn : IN std_logic_vector(4 downto 0);
        rstwoIn : IN std_logic_vector(4 downto 0);
        rdaluIn : IN std_logic_vector(4 downto 0);
        rdmemIn : IN std_logic_vector(4 downto 0);
        AluForwardingOneOut : OUT std_logic;
        MemForwardingOneOut : OUT std_logic;
        AluForwardingTwoOut : OUT std_logic;
        MemForwardingTwoOut : OUT std_logic);
end FWU;

architecture BEHAVIORAL of FWU is

  begin

    FWD_PROCESS : process (rsoneIn, rstwoIn, rdaluIn, rdmemIn)
    begin
      if rsoneIn = rdaluIn and rsOneIn /= "00000" and (opcode = R_TYPE or opcode = I_TYPE) then
        AluForwardingOneOut <= '1';
      else
        AluForwardingOneOut <= '0';
      end if;
      if rsoneIn = rdmemIn and rsOneIn /= "00000" and (opcode = R_TYPE or opcode = I_TYPE) then
        MemForwardingOneOut <= '1';
      else
        MemForwardingOneOut <= '0';
      end if;
      if rstwoIn = rdaluIn and rsTwoIn /= "00000" and (opcode = R_TYPE or opcode = I_TYPE) then
        AluForwardingTwoOut <= '1';
      else
        AluForwardingTwoOut <= '0';
      end if;
      if rstwoIn = rdmemIn and rsTwoIn /= "00000" and (opcode = R_TYPE or opcode = I_TYPE) then
        MemForwardingTwoOut <= '1';
      else
        MemForwardingTwoOut <= '0';
      end if;
    end process FWD_PROCESS;

  end BEHAVIORAL;

configuration CFG_FWU_BEHAVIORAL of FWU is
  for BEHAVIORAL
  end for;
end CFG_FWU_BEHAVIORAL;
