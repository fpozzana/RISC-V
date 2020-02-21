library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity memwbReg is
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
end memwbReg;

architecture structural of memwbReg is
  component REGISTER_GENERIC
  generic (NBIT : integer := NumBitRegister);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  component FD
  port(D :	IN	std_logic;
			CK :	IN	std_logic;
			RESET :	IN	std_logic;
			Q :	OUT	std_logic);
  end component;


  begin

    --DMEMREG : REGISTER_GENERIC
    --generic map(32)
    --port map(dmemData, clk, rst, dmemDataOut);

    dmemDataOut <= dmemData;

    ALUDATAREG : REGISTER_GENERIC
    generic map(32)
    port map(aluData, clk, rst, aluDataOut);

    RDREGISTER : REGISTER_GENERIC
    generic map(5)
    port map(rdReg, clk, rst, rdRegOut);

    DATASELREG : FD
    port map(dataSel, clk, rst, dataSelOut);

    RFWRITEREG : FD
    port map(rfWrite, clk, rst, rfWriteOut);

end structural;

configuration CFG_MEMWBREG_STRUCTURAL of memwbReg is
  for structural
    for all : FD
      use configuration WORK.CFG_FD_SYNC;
    end for;
    for all : REGISTER_GENERIC
      use configuration WORK.CFG_REGISTER_GENERIC_STRUCTURAL_SYNC;
    end for;
  end for;
end configuration;
