library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity TB_MUX3TO1 is
end TB_MUX3TO1;

architecture TEST of TB_MUX3TO1 is

  signal OperandIn, AluForwarded, MemForwarded : std_logic_vector(31 downto 0);
  signal AluForwardSignal, MemForwardSignal : std_logic;
  signal MuxOut : std_logic_vector(31 downto 0);

  component MUX3TO1
  port(OperandIn : IN std_logic_vector(31 downto 0);
       AluForwarded : IN std_logic_vector(31 downto 0);
       MemForwarded : IN std_logic_vector(31 downto 0);
       AluForwardSignal : IN std_logic;
       MemForwardSignal : IN std_logic;
       MuxOut : OUT std_logic_vector(31 downto 0));
  end component;

  begin

    DUT : MUX3TO1
    port map(OperandIn, AluForwarded, MemForwarded, AluForwardSignal, MemForwardSignal, MuxOut);

    OperandIn <= "00000000000000000000000000000000";
    AluForwarded <= "00000000000000000000000000000001";
    MemForwarded <= "00000000000000000000000000000010";
    AluForwardSignal <= '0','1' after 15 ns;
    MemForwardSignal <= '0', '1' after 10 ns, '0' after 20 ns;

end TEST;

configuration CFG_TB_MUX3TO1 of TB_MUX3TO1 is
  for TEST
    for DUT : MUX3TO1
      use configuration WORK.CFG_MUX3TO1_STRUCTURAL;
    end for;
  end for;
end CFG_TB_MUX3TO1;
