library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity tbexmemReg is
end tbexmemReg;

architecture test of tbexmemReg is
  signal clk, rst, dataSel, memenable, memrw, rfWrite : std_logic := '0';
  signal aluResult, rf2Result : std_logic_vector(31 downto 0) := (others => '0');
  signal rdReg : std_logic_vector(4 downto 0) := (others => '0');
  signal rdRegOut : std_logic_vector(4 downto 0);
  signal dataSelOut, memrwOut, memenableOut, rfWriteOut : std_logic;
  signal aluResultOut, rf2ResultOut : std_logic_vector(31 downto 0);
  signal memfunct3In : std_logic_vector(2 downto 0) := (others => '0');
  signal memfunct3Out : std_logic_vector(2 downto 0);

  component exmemReg
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
  end component;

  begin

    DUT : exmemReg
    port map(clk => clk,
             rst => rst,
             memenable => memenable,
             memrw => memrw,
             memfunct3In => memfunct3In,
             dataSel => dataSel,
             rdReg => rdReg,
             aluResult => aluResult,
             rf2Result => rf2Result,
             rfWrite => rfWrite,
             memenableOut => memenableOut,
             memrwOut => memrwOut,
             memfunct3Out => memfunct3Out,
             dataSelOut => dataSelOut,
             rdRegOut => rdRegOut,
             aluResultOut => aluResultOut,
             rf2ResultOut => rf2ResultOut,
             rfWriteOut => rfWriteOut);

    PCLOCK : process(clk)
    begin
      clk <= not(clk) after 1 ns;
    end process;

    rst <= '1' after 1 ns;
    memenable <= '1' after 2 ns;
    memrw <= '1' after 2 ns;
    dataSel <= '1' after 2 ns;
    rdReg <= (others => '1') after 2 ns;
    aluResult <= (others => '1') after 2 ns;
    rf2Result <= (others => '1') after 2 ns;

end test;

configuration CFG_TB_EXMEMREG of tbexmemReg is
  for test
    for DUT : exmemReg
      use configuration WORK.CFG_EXMEMREG_STRUCTURAL;
    end for;
  end for;
end CFG_TB_EXMEMREG;
