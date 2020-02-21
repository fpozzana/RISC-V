library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity TB_REGISTER_ENABLE is
end TB_REGISTER_ENABLE;

architecture TEST of TB_REGISTER_ENABLE is

  constant NBIT : integer := NumBitRegister;
  signal D_IN : std_logic_vector(NBIT-1 downto 0) := "00000000000000000000000000000000";
  signal CLK_IN : std_logic := '0';
  signal RESET_IN : std_logic := '1';
  signal ENABLE_IN : std_logic := '0';
  signal Q_OUT_SYNC : std_logic_vector(NBIT-1 downto 0);

  component REGISTER_ENABLE
  generic (NBIT : integer := NumBitRegisterEnable);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    ENABLE : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  begin

    DUT1 : REGISTER_ENABLE
    generic map(NBIT)
    port map(D_IN,CLK_IN,ENABLE_IN,RESET_IN,Q_OUT_SYNC);


    D_IN <= "10001000100010001000100010001000", "00010001000100010001000100010001" after 5 ns, "10001000100010001000100010001000" after 15 ns;
    RESET_IN <= '0' after 3 ns,'1' after 10 ns;
    ENABLE_IN <= '1' after 10 ns, '0' after 20 ns;

    PCLOCK : process(CLK_IN)
    begin
      CLK_IN <= not(CLK_IN) after 1 ns;
    end process;

  end TEST;

configuration CFG_TB_REGISTER_ENABLE of TB_REGISTER_ENABLE is
  for TEST
    for DUT1 : REGISTER_ENABLE
      use configuration WORK.CFG_REGISTER_ENABLE;
    end for;
  end for;
end CFG_TB_REGISTER_ENABLE;
