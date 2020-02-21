library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity ND2 is
  port (
    A : IN std_logic;
    B : IN std_logic;
    Y : OUT std_logic);
end ND2;

architecture BEHAVIORAL of ND2 is
  begin
    Y <= not (A and B);
end BEHAVIORAL;

configuration CFG_ND2_BEHAVIORAL of ND2 is
  for BEHAVIORAL
  end for;
end CFG_ND2_BEHAVIORAL;
