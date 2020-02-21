-- if SEL == '0' => Y == A else Y == B
--test : tested OK, the component works as expected

library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity MUX21_GENERIC is
  generic (NBIT : integer := NumBitMux21);
  port(A : IN std_logic_vector(NBIT-1 downto 0);
       B : IN std_logic_vector(NBIT-1 downto 0);
       SEL : IN std_logic;
       Y : OUT std_logic_vector(NBIT-1 downto 0));
end MUX21_GENERIC;

architecture BEHAVIORAL of MUX21_GENERIC is
  begin
    Y <= A when SEL = '0' else B;
end BEHAVIORAL;

architecture STRUCTURAL of MUX21_GENERIC is

  signal SEL_INV : std_logic_vector(NBIT-1 downto 0);            -- support signal for the not(SEL)
  signal NAND_ONE_OUT : std_logic_vector(NBIT-1 downto 0);       -- support signal for output of first nand
  signal NAND_TWO_OUT : std_logic_vector(NBIT-1 downto 0);       -- support signal for output of second nand

  component ND2                                                  -- instantiating nand2 component
  port (A : IN std_logic;
        B : IN std_logic;
        Y : OUT std_logic);
  end component;

  component IV                                                   -- instantiating inverter component
  port (A : IN std_logic;
        Y : OUT std_logic);
  end component;

   begin

     MUX_GENERATE : for i in 0 to NBIT-1 generate
       UIV : IV
       port map(SEL,SEL_INV(i));
       UND1 : ND2
       port map(A(i),SEL_INV(i),NAND_ONE_OUT(i));
       UND2 : ND2
       port map(B(i),SEL,NAND_TWO_OUT(i));
       UND3 : ND2
       port map(NAND_ONE_OUT(i),NAND_TWO_OUT(i),Y(i));
    end generate MUX_GENERATE;

end STRUCTURAL;

configuration CFG_MUX21_GENERIC_BEHAVIORAL of MUX21_GENERIC is
  for BEHAVIORAL
  end for;
end CFG_MUX21_GENERIC_BEHAVIORAL;

configuration CFG_MUX21_GENERIC_STRUCTURAL of MUX21_GENERIC is
  for STRUCTURAL
    for MUX_GENERATE
      for all : IV
        use configuration WORK.CFG_IV_BEHAVIORAL;
      end for;
      for all : ND2
        use configuration WORK.CFG_ND2_BEHAVIORAL;
      end for;
    end for;
  end for;
end CFG_MUX21_GENERIC_STRUCTURAL;
