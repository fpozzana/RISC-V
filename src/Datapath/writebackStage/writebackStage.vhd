library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity writebackStage is
  port (dataSel :	IN std_logic;
        dmemData : IN std_logic_vector(31 downto 0);
        aluData : IN std_logic_vector(31 downto 0);
        wbOut : OUT std_logic_vector(31 downto 0));
end writebackStage;

architecture structural of writebackStage is
  component MUX21_GENERIC
  generic (NBIT : integer := NumBitMux21);
  port(A : IN std_logic_vector(NBIT-1 downto 0);
       B : IN std_logic_vector(NBIT-1 downto 0);
       SEL : IN std_logic;
       Y : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  begin

    MUXPC : MUX21_GENERIC
    generic map(32)
    port map(aluData, dmemData, dataSel, wbOut);

end structural;

configuration CFG_WRITEBACKSTAGE_STRUCTURAL of writebackStage is
  for structural
    for all : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_STRUCTURAL;
    end for;
  end for;
end configuration;
