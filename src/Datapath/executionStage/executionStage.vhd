--aluSrcIn(0) for operand a and npc, aluSrcIn(1) for operand b and immediate

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity executionStage is
  port (opcode : IN std_logic_vector(6 downto 0);
        rfoneIn : IN std_logic_vector(31 downto 0);
        rftwoIn : IN std_logic_vector(31 downto 0);
        immIn : IN std_logic_vector(31 downto 0);
        npcIn : IN std_logic_vector(31 downto 0);
        pcIn : IN std_logic_vector(31 downto 0);
        AluForwardedIn : IN std_logic_vector(31 downto 0);
        MemForwardedIn : IN std_logic_vector(31 downto 0);
        --pcSrcIn : IN std_logic;
        aluSrcIn : IN std_logic_vector(1 downto 0);
        aluControlIn : IN std_logic_vector(4 downto 0);
        aluShamtIn : IN std_logic_vector(4 downto 0);
        rsoneIn : IN std_logic_vector(4 downto 0);
        rstwoIn : IN std_logic_vector(4 downto 0);
        rdaluIn : IN std_logic_vector(4 downto 0);
        rdmemIn : IN std_logic_vector(4 downto 0);
        aluOut : OUT std_logic_vector(31 downto 0));
end executionStage;

architecture structural of executionStage is
  component MUX21_GENERIC
  generic (NBIT : integer := NumBitMux21);
  port(A : IN std_logic_vector(NBIT-1 downto 0);
       B : IN std_logic_vector(NBIT-1 downto 0);
       SEL : IN std_logic;
       Y : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  component MUX3TO1
  port(OperandIn : IN std_logic_vector(31 downto 0);
       AluForwarded : IN std_logic_vector(31 downto 0);
       MemForwarded : IN std_logic_vector(31 downto 0);
       AluForwardSignal : IN std_logic;
       MemForwardSignal : IN std_logic;
       MuxOut : OUT std_logic_vector(31 downto 0));
  end component;

  component ALU
  port (op : IN std_logic_vector(4 downto 0);
        operand_a : IN std_logic_vector(31 downto 0);
        operand_b : IN std_logic_vector(31 downto 0);
        operand_shamt : IN std_logic_vector(4 downto 0);
        aluOut: OUT std_logic_vector(31 downto 0));
  end component;

  component FWU
  port (opcode : IN std_logic_vector(6 downto 0);
        rsoneIn : IN std_logic_vector(4 downto 0);
        rstwoIn : IN std_logic_vector(4 downto 0);
        rdaluIn : IN std_logic_vector(4 downto 0);
        rdmemIn : IN std_logic_vector(4 downto 0);
        AluForwardingOneOut : OUT std_logic;
        MemForwardingOneOut : OUT std_logic;
        AluForwardingTwoOut : OUT std_logic;
        MemForwardingTwoOut : OUT std_logic);
  end component;

  signal topmuxout, bottommuxout : std_logic_vector(31 downto 0);
  signal topalu, bottomalu : std_logic_vector(31 downto 0);
  signal AluForwardSignalOne, MemForwardSignalOne : std_logic;
  signal AluForwardSignalTwo, MemForwardSignalTwo : std_logic;

  --signal totopmuxpc : std_logic_vector(31 downto 0);

  begin

    --PCNPC : MUX21_GENERIC
    --generic map(32)
    --port map(npcIn, pcIn, pcSrcIn, totopmuxpc);

    --TOPMUX : MUX21_GENERIC
    --generic map(32)
    --port map(rfoneIn, totopmuxpc, aluSrcIn(0), topmuxout);

    TOPMUX : MUX21_GENERIC
    generic map(32)
    port map(rfoneIn, pcIn, aluSrcIn(0), topmuxout);

    BOTTOMMUX : MUX21_GENERIC
    generic map(32)
    port map(rftwoIn, immIn, aluSrcIn(1), bottommuxout);

    TOP3TO1MUX : MUX3TO1
    port map(topmuxout, AluForwardedIn, MemForwardedIn, AluForwardSignalOne, MemForwardSignalOne, topalu);

    BOTTOM3TO1MUX : MUX3TO1
    port map(bottommuxout, AluForwardedIn, MemForwardedIn, AluForwardSignalTwo, MemForwardSignalTwo, bottomalu);

    ALUINST : ALU
    port map(aluControlIn, topalu, bottomalu, aluShamtIn, aluOut);

    FWUINST : FWU
    port map(opcode, rsoneIn, rstwoIn, rdaluIn, rdmemIn, AluForwardSignalOne, MemForwardSignalOne, AluForwardSignalTwo, MemForwardSignalTwo);

end structural;

configuration CFG_EXECUTIONSTAGE_STRUCTURAL of executionStage is
  for structural
    for all : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_STRUCTURAL;
    end for;
    for all : MUX3TO1
      use configuration WORK.CFG_MUX3TO1_STRUCTURAL;
    end for;
    for all : ALU
      use configuration WORK.CFG_ALU_BEHAVIORAL;
    end for;
    for all : FWU
      use configuration WORK.CFG_FWU_BEHAVIORAL;
    end for;
  end for;
end configuration;
