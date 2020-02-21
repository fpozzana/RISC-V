library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity fetchStage is
  port (clk :	IN std_logic;
        rst : IN std_logic;
        enable : IN std_logic;
        pcBranchIn : IN std_logic_vector(31 downto 0);
        imOut : OUT std_logic_vector(31 downto 0);
        pcOut : OUT std_logic_vector(31 downto 0);
        npcOut : OUT std_logic_vector(31 downto 0));
end fetchStage;

architecture structural of fetchStage is

  component REGISTER_ENABLE
  generic (NBIT : integer := NumBitRegisterEnable);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    ENABLE : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  signal addSignal : std_logic_vector(31 downto 0);
  signal imOutSignal : std_logic_vector(31 downto 0);

  constant plusFour : std_logic_vector(31 downto 0) := "00000000000000000000000000000100";

  begin

    addSignal <= plusFour + imOutSignal;

    --PCREG : REGISTER_ENABLE
    --generic map(32)
    --port map(pcBranchIn, clk, enable, rst, imOutSignal);

    imOutSignal <= pcBranchIn;

    imOut <= "00" & imOutSignal(31 downto 2);
    pcOut <= imOutSignal;
    npcOut <= addSignal;

end structural;

configuration CFG_FETCHSTAGE_STRUCTURAL of fetchStage is
  for structural
    --for all : REGISTER_ENABLE
      --use configuration WORK.CFG_REGISTER_ENABLE;
    --end for;
  end for;
end configuration;
