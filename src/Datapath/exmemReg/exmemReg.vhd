library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity exmemReg is
  port (clk :	IN std_logic;
        rst : IN std_logic;
        memenable : IN std_logic;
        memrw : IN std_logic;
        memfunct3In : In std_logic_vector(2 downto 0);
        dataSel : IN std_logic;
        rdReg : IN std_logic_vector(4 downto 0);
        aluResult : IN std_logic_vector(31 downto 0);
        rf2Result : IN std_logic_vector(31 downto 0);
        rfWrite : IN std_logic;
        memenableOut : OUT std_logic;
        memrwOut : OUT std_logic;
        memfunct3Out : OUT std_logic_vector(2 downto 0);
        dataSelOut : OUT std_logic;
        rdRegOut : OUT std_logic_vector(4 downto 0);
        aluResultOut : OUT std_logic_vector(31 downto 0);
        rf2ResultOut : OUT std_logic_vector(31 downto 0);
        rfWriteOut : OUT std_logic);
end exmemReg;

architecture structural of exmemReg is
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

    RDREGISTER : REGISTER_GENERIC
    generic map(5)
    port map(rdReg, clk, rst, rdRegOut);

    ALURESULTREGISTER : REGISTER_GENERIC
    generic map(32)
    port map(aluResult, clk, rst, aluResultOut);

    RF2RESULTREGISTER : REGISTER_GENERIC
    generic map(32)
    port map(rf2Result, clk, rst, rf2ResultOut);

    DATASELREG : FD
    port map(dataSel, clk, rst, dataSelOut);

    MEMENABLEREG : FD
    port map(memenable, clk, rst, memenableOut);

    MEMRWREG : FD
    port map(memrw, clk, rst, memrwOut);

    memfunct3REG : REGISTER_GENERIC
    generic map(3)
    port map(memfunct3In, clk, rst, memfunct3Out);

    RFWRITEREG : FD
    port map(rfWrite, clk, rst, rfWriteOut);

end structural;

configuration CFG_EXMEMREG_STRUCTURAL of exmemReg is
  for structural
    for all : FD
      use configuration WORK.CFG_FD_SYNC;
    end for;
    for all : REGISTER_GENERIC
      use configuration WORK.CFG_REGISTER_GENERIC_STRUCTURAL_SYNC;
    end for;
  end for;
end configuration;
