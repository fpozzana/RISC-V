-- RESET is active low, so if RESET is 1 the register has '0' at the output
--ENABLE is active low, so if ENABLE is 1 the register samples, otherwise keeps the old value
--test : tested OK, the component works as expected

library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity REGISTER_ENABLE is
  generic (NBIT : integer := NumBitRegisterEnable);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    ENABLE : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
end REGISTER_ENABLE;

architecture beahvioral of REGISTER_ENABLE is

  begin

    proc : process(CK, ENABLE, RESET)
      begin
        if RESET = '0' then
          Q <= (others => '0');
        elsif (CK'event and CK = '1' and ENABLE = '0') then
            Q <= D;
        end if;
      end process;

end architecture;

configuration CFG_REGISTER_ENABLE of REGISTER_ENABLE is
  for beahvioral
  end for;
end configuration;
