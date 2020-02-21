library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity tbmemwbReg is
end tbmemwbReg;

architecture test of tbmemwbReg is
  signal clk, rst, dataSel, rfWrite : std_logic := '0';
  signal dmemData, aluData, dmemDataOut, aluDataOut : std_logic_vector(31 downto 0);
  signal rdReg, rdRegOut : std_logic_vector(4 downto 0);
  signal dataSelOut, rfWriteOut : std_logic;

  component memwbReg
  port (clk :	IN std_logic;
        rst : IN std_logic;
        dataSel : IN std_logic;
        dmemData : IN std_logic_vector(31 downto 0);
        aluData : IN std_logic_vector(31 downto 0);
        rdReg : IN std_logic_vector(4 downto 0);
        rfWrite : IN std_logic;
        dataSelOut : OUT std_logic;
        dmemDataOut : OUT std_logic_vector(31 downto 0);
        aluDataOut : OUT std_logic_vector(31 downto 0);
        rdRegOut : OUT std_logic_vector(4 downto 0);
        rfWriteOut : OUT std_logic);
  end component;

  begin

    DUT : memwbReg
    port map(clk => clk,
             rst => rst,
             dataSel => dataSel,
             dmemData => dmemData,
             aluData => aluData,
             rdReg => rdReg,
             rfWrite => rfWrite,
             dataSelOut => dataSelOut,
             dmemDataOut => dmemDataOut,
             aluDataOut => aluDataOut,
             rdRegOut => rdRegOut,
             rfWriteOut => rfWriteOut);

    PCLOCK : process(clk)
    begin
      clk <= not(clk) after 1 ns;
    end process;

    dataSel <= '1' after 21 ns;
    dmemData <= "00000000000000000000000000000000", "10001000100010001000100010001000" after 20 ns;
    aluData <= "00000000000000000000000000000000", "10001000100010001000100010001000" after 21 ns;
    rdReg <= "00000", "10010" after 21 ns;
    rst <= '1' after 3 ns;

end test;

configuration CFG_TB_MEMWBREG of tbmemwbReg is
  for test
    for DUT : memwbReg
      use configuration WORK.CFG_MEMWBREG_STRUCTURAL;
    end for;
  end for;
end CFG_TB_MEMWBREG;
