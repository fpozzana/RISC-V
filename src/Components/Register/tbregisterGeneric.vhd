library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity TB_REGISTER_GENERIC is
end TB_REGISTER_GENERIC;

architecture TEST of TB_REGISTER_GENERIC is

  constant NBIT : integer := NumBitRegister;
  signal D_IN : std_logic_vector(NBIT-1 downto 0) := "00000000000000000000000000000000";
  signal CLK_IN : std_logic := '0';
  signal RESET_IN : std_logic := '1';
  signal Q_OUT_SYNC : std_logic_vector(NBIT-1 downto 0);

  component REGISTER_GENERIC
  generic (NBIT : integer := NumBitRegister);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  begin

    DUT1 : REGISTER_GENERIC
    generic map(NBIT)
    port map(D_IN,CLK_IN,RESET_IN,Q_OUT_SYNC);


    D_IN <= "10001000100010001000100010001000", "00010001000100010001000100010001" after 5 ns;
    RESET_IN <= '0' after 3 ns,'1' after 15 ns,'0' after 18.5 ns;

    PCLOCK : process(CLK_IN)
    begin
      CLK_IN <= not(CLK_IN) after 1 ns;
    end process;

  end TEST;

configuration CFG_TB_REGISTER_GENERIC of TB_REGISTER_GENERIC is
  for TEST
    for DUT1 : REGISTER_GENERIC
      use configuration WORK.CFG_REGISTER_GENERIC_STRUCTURAL_SYNC;
    end for;
  end for;
end CFG_TB_REGISTER_GENERIC;
