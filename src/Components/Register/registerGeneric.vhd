-- RESET is active low, so if RESET is 1 the register has '0' at the output
--test : tested OK, the component works as expected

library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity REGISTER_GENERIC is
  generic (NBIT : integer := NumBitRegister);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
end REGISTER_GENERIC;

architecture STRUCTURAL_SYNC of REGISTER_GENERIC is

  component FD
  port (	D :	IN	std_logic;
		      CK :	IN	std_logic;
		      RESET : IN	std_logic;
		      Q :	OUT	std_logic);
  end component;

  begin
    REGISTER_GENERATE_SYNC : for i in 0 to NBIT-1 generate
      UFD : FD
      port map(D(i),CK,RESET,Q(i));
    end generate REGISTER_GENERATE_SYNC;
end STRUCTURAL_SYNC;


configuration CFG_REGISTER_GENERIC_STRUCTURAL_SYNC of REGISTER_GENERIC is
  for STRUCTURAL_SYNC
    for REGISTER_GENERATE_SYNC
      for all : FD
        use configuration WORK.CFG_FD_SYNC;
      end for;
    end for;
  end for;
end CFG_REGISTER_GENERIC_STRUCTURAL_SYNC;
