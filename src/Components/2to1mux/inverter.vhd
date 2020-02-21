library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;               

entity IV is
  port (
    A : IN std_logic;
    Y : OUT std_logic);
end IV;

architecture BEHAVIORAL of IV is
  begin
    Y <= not(A);
end BEHAVIORAL;

configuration CFG_IV_BEHAVIORAL of IV is
  for BEHAVIORAL
  end for;
end CFG_IV_BEHAVIORAL;
