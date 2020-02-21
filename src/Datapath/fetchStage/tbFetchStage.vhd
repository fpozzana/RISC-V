library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity tbfetchStage is
end tbfetchStage;

architecture test of tbfetchStage is
  signal clk, rst : std_logic := '0';
  signal pcBranchIn, imOut, pcOut, npcOut : std_logic_vector(31 downto 0);
  signal enable : std_logic := '0';

  component fetchStage
  port (clk :	IN std_logic;
        rst : IN std_logic;
        enable : IN std_logic;
        pcBranchIn : IN std_logic_vector(31 downto 0);
        imOut : OUT std_logic_vector(31 downto 0);
        pcOut : OUT std_logic_vector(31 downto 0);
        npcOut : OUT std_logic_vector(31 downto 0));
  end component;

  begin

    DUT : fetchStage
    port map(clk => clk,
             rst => rst,
             enable => enable,
             pcBranchIn => pcBranchIn,
             imOut => imOut,
             pcOut => pcOut,
             npcOut => npcOut);

    PCLOCK : process(clk)
    begin
      clk <= not(clk) after 1 ns;
    end process;

    rst <= '1' after 3 ns;
    pcBranchIn <= "00000000000000000000000000000000", "00000000000000000000000000000100" after 5 ns,"00000000000000000000000000001000" after 7 ns ;
    enable <= '1' after 6 ns;

end test;

configuration CFG_TB_FETCHSTAGE of tbfetchStage is
  for test
    for DUT : fetchStage
      use configuration WORK.CFG_FETCHSTAGE_STRUCTURAL;
    end for;
  end for;
end CFG_TB_FETCHSTAGE;
