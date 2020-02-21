--if OUT signal is 0 means no hazard have been detected

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;

entity HDU is
  port (rst : IN std_logic;
        memReadAluIn : IN std_logic;
        memReadMemIn : IN std_logic;
        rdAluIn : IN std_logic_vector(4 downto 0);
        rdMemIn : IN std_logic_vector(4 downto 0);
        rsOneIn : IN std_logic_vector(4 downto 0);
        rsTwoIn : IN std_logic_vector(4 downto 0);
        hazardOut : OUT std_logic);
end HDU;

architecture BEHAVIORAL of HDU is

  begin

    HDU_PROCESS : process (memReadAluIn, memReadMemIn, rsOneIn, rsTwoIn, rdAluIn, rdMemIn, rst)
    begin
      if rst = '0' then
        hazardOut <= '0';
      elsif memReadAluIn = '1' and memReadMemIn = '0' then
        if rdAluIn = rsOneIn or rdAluIn = rsTwoIn then
          hazardOut <= '1';
        else
          hazardOut <= '0';
        end if;
      elsif memReadAluIn = '0' and memReadMemIn = '1' then
        if rdMemIn = rsOneIn or rdMemIn = rsTwoIn then
          hazardOut <= '1';
        else
          hazardOut <= '0';
        end if;
      elsif memReadAluIn = '1' and memReadMemIn = '1' then
        if rdAluIn = rsOneIn or rdAluIn = rsTwoIn then
          hazardOut <= '1';
        elsif rdMemIn = rsOneIn or rdMemIn = rsTwoIn then
          hazardOut <= '1';
        else
          hazardOut <= '0';
        end if;
      elsif memReadAluIn = '0' and memReadMemIn = '0' then
        hazardOut <= '0';
      end if;
    end process HDU_PROCESS;



  end BEHAVIORAL;

configuration CFG_HDU_BEHAVIORAL of HDU is
  for BEHAVIORAL
  end for;
end CFG_HDU_BEHAVIORAL;
