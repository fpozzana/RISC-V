library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity TB_MUX21_GENERIC is
end TB_MUX21_GENERIC;

architecture TEST of TB_MUX21_GENERIC is

  constant NBIT : integer := NumBitMux21;
  signal A_IN : std_logic_vector(NBIT-1 downto 0);
  signal B_IN : std_logic_vector(NBIT-1 downto 0);
  signal SEL_IN : std_logic;
  signal OUT_BEHAVIORAL : std_logic_vector(NBIT-1 downto 0);
  signal OUT_STRUCTURAL : std_logic_vector(NBIT-1 downto 0);

  component MUX21_GENERIC
  generic (NBIT : integer := NumBitMux21);
  port(A : IN std_logic_vector(NBIT-1 downto 0);
       B : IN std_logic_vector(NBIT-1 downto 0);
       SEL : IN std_logic;
       Y : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  begin

    DUT1 : MUX21_GENERIC
    generic map(NBIT)
    port map(A_IN,B_IN,SEL_IN,OUT_BEHAVIORAL);

    DUT2 : MUX21_GENERIC
    generic map(NBIT)
    port map(A_IN,B_IN,SEL_IN,OUT_STRUCTURAL);

    A_IN <= "10000000000000000000000000000000";           --testing only for one value of A_IN
    B_IN <= "00000000000000000000000000000001";           --testing only for one value of B_IN
    SEL_IN <= '0','1' after 5 ns;                         --testing only for one switch

end TEST;

configuration CFG_TB_MUX21_GENERIC of TB_MUX21_GENERIC is
  for TEST
    for DUT1 : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_BEHAVIORAL;
    end for;
    for DUT2 : MUX21_GENERIC
       use configuration WORK.CFG_MUX21_GENERIC_STRUCTURAL;
    end for;
  end for;
end CFG_TB_MUX21_GENERIC;
