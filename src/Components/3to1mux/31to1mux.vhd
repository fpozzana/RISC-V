library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity MUX3TO1 is
  port(OperandIn : IN std_logic_vector(31 downto 0);
       AluForwarded : IN std_logic_vector(31 downto 0);
       MemForwarded : IN std_logic_vector(31 downto 0);
       AluForwardSignal : IN std_logic;
       MemForwardSignal : IN std_logic;
       MuxOut : OUT std_logic_vector(31 downto 0));
end MUX3TO1;

architecture STRUCTURAL of MUX3TO1 is

  signal muxInternal : std_logic_vector(31 downto 0);

  component MUX21_GENERIC
  generic (NBIT : integer := NumBitMux21);
  port(A : IN std_logic_vector(NBIT-1 downto 0);
       B : IN std_logic_vector(NBIT-1 downto 0);
       SEL : IN std_logic;
       Y : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  begin

    FIRSTMUX : MUX21_GENERIC
    generic map(32)
    port map(OperandIn, MemForwarded, MemForwardSignal, muxInternal);

    SECONDMUX : MUX21_GENERIC
    generic map(32)
    port map(muxInternal, AluForwarded, AluForwardSignal, MuxOut);

end STRUCTURAL;


configuration CFG_MUX3TO1_STRUCTURAL of MUX3TO1 is
  for STRUCTURAL
    for all : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_STRUCTURAL;
    end for;
  end for;
end CFG_MUX3TO1_STRUCTURAL;
