library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity tbexecutionStage is
end tbexecutionStage;

architecture test of tbexecutionStage is

  signal rfoneIn, rftwoIn, immIn, npcIn, AluForwardedIn, MemForwardedIn, aluOut, pcIn : std_logic_vector(31 downto 0);
  signal aluSrcIn : std_logic_vector(1 downto 0);
  signal aluControlIn, aluShamtIn, rsoneIn, rstwoIn, rdaluIn, rdmemIn : std_logic_vector(4 downto 0);
  --signal pcSrcIn : std_logic;
  signal opcode : std_logic_vector(6 downto 0) := R_TYPE;

  component executionStage
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
  end component;

  begin

    DUT : executionStage
    port map(opcode => opcode,
             rfoneIn => rfoneIn,
             rftwoIn => rftwoIn,
             immIn => immIn,
             npcIn => npcIn,
             pcIn => pcIn,
             AluForwardedIn => AluForwardedIn,
             MemForwardedIn => MemForwardedIn,
             aluSrcIn => aluSrcIn,
             --pcSrcIn => pcSrcIn,
             aluControlIn => aluControlIn,
             aluShamtIn => aluShamtIn,
             rsoneIn => rsoneIn,
             rstwoIn => rstwoIn,
             rdaluIn => rdaluIn,
             rdmemIn => rdmemIn,
             aluOut => aluOut);

    rfoneIn <= "00000000000000000000000000000001";
    rftwoIn <= "00000000000000000000000000000010";
    immIn <= "00000000000000000000000000000011";
    npcIn <= "00000000000000000000000000000100";
    pcIn <= "00000000000000000000000000000000";
    AluForwardedIn <= "00000000000000000000000000000101";
    MemForwardedIn <= "00000000000000000000000000000110";
    aluSrcIn <= "00", "01" after 10 ns, "10" after 20 ns, "11" after 30 ns;
    --pcSrcIn <= '0', '1' after 45 ns;
    rdaluIn <= "11111", "00000" after 40 ns;
    rdmemIn <= "11111", "00000" after 35 ns;
    aluControlIn <= "00110";
    aluShamtIn <= "00000";
    rsoneIn <= "00000", "11001" after 38 ns, "11111" after 40 ns;
    rstwoIn <= "00000", "11111" after 40 ns;

end test;

configuration CFG_TB_EXECUTIONSTAGE of tbexecutionStage is
  for test
    for DUT : executionStage
      use configuration WORK.CFG_EXECUTIONSTAGE_STRUCTURAL;
    end for;
  end for;
end CFG_TB_EXECUTIONSTAGE;
