library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity tbwritebackStage is
end tbwritebackStage;

architecture test of tbwritebackStage is
  signal dataSel : std_logic := '0';
  signal dmemData, aluData, wbOut : std_logic_vector(31 downto 0);

  component writebackStage
  port (dataSel :	IN std_logic;
        dmemData : IN std_logic_vector(31 downto 0);
        aluData : IN std_logic_vector(31 downto 0);
        wbOut : OUT std_logic_vector(31 downto 0));
  end component;

  begin

    DUT : writebackStage
    port map(dataSel => dataSel,
             dmemData => dmemData,
             aluData => aluData,
             wbOut => wbOut);

    dataSel <= '1' after 20 ns;
    dmemData <= "00000000000000000000000000000000";
    aluData <= "10001000100010001000100010001000";

end test;

configuration CFG_TB_WRITEBACKSTAGE of tbwritebackStage is
  for test
    for DUT : writebackStage
      use configuration WORK.CFG_WRITEBACKSTAGE_STRUCTURAL;
    end for;
  end for;
end CFG_TB_WRITEBACKSTAGE;
