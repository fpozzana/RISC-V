library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity tbidexReg is
end tbidexReg;

architecture test of tbidexReg is
  signal clk, rst, dataSel, memWrite, memRead, rfWrite, CU_enable, CU_datamem_rw, CU_write_enable, CU_dataSel : std_logic := '0';
  signal CU_aluSrcIn : std_logic_vector(1 downto 0) := "00";
  signal rf1, rf2, pc, imm : std_logic_vector(31 downto 0) := (others => '0');
  signal rdReg, rs1Reg, rs2Reg, aluControl, aluShamt : std_logic_vector(4 downto 0) := (others => '0');
  signal rdRegOut, rs1RegOut, rs2RegOut, aluControlOut, aluShamtOut : std_logic_vector(4 downto 0);
  signal dataSelOut, memWriteOut, memReadOut, rfWriteOut, CU_enableOut, CU_datamem_rwOut, CU_dataSelOut, CU_write_enableOut : std_logic;
  signal aluSrcOut : std_logic_vector(1 downto 0);
  signal rf1Out, rf2Out, pcOut, immOut : std_logic_vector(31 downto 0);
  signal funct3In : std_logic_vector(2 downto 0) := "000";
  signal funct3Out : std_logic_vector(2 downto 0);
  --signal CU_pcSrcIn : std_logic := '0';
  --signal CU_pcSrcOut : std_logic;
  signal npc : std_logic_vector(31 downto 0) := (others => '0');
  signal npcOut : std_logic_vector(31 downto 0);
  signal opcodeIn : std_logic_vector(6 downto 0) := "1110001";
  signal opcodeOut : std_logic_vector(6 downto 0);

  component idexReg
  port (clk :	IN std_logic;
        rst : IN std_logic;
	-- from decode stage
        opcodeIn : IN std_logic_vector(6 downto 0);
        aluControl : IN std_logic_vector(4 downto 0);
        aluShamt : IN std_logic_vector(4 downto 0);
        rs1Reg : IN std_logic_vector(4 downto 0);
        rs2Reg : IN std_logic_vector(4 downto 0);
        rdReg : IN std_logic_vector(4 downto 0);
        rf1 : IN std_logic_vector(31 downto 0);
        rf2 : IN std_logic_vector(31 downto 0);
	imm : IN std_logic_vector(31 downto 0);  -- from imm extender
        npc : IN std_logic_vector(31 downto 0);  -- from BDU
        pc : IN std_logic_vector(31 downto 0); -- from fetch
	---- from CU (located in decode stage)
	-- exe stage
	CU_aluSrcIn : IN std_logic_vector(1 downto 0);
  --CU_pcSrcIn     : in std_logic; -- always 0, 1 if AUIPC
  funct3In : in std_logic_vector(2 downto 0);
        -- memory stage
	CU_enable : IN std_logic;
        CU_datamem_rw : IN std_logic;

	-- write back stage
	CU_write_enable : in std_logic;
	CU_dataSel : IN std_logic;

	---- OUTPUTS ----
	-- to execution stage
        opcodeOut : OUT std_logic_vector(6 downto 0);
        aluSrcOut : OUT std_logic_vector(1 downto 0); -- control muxes before ALU
        aluControlOut : OUT std_logic_vector(4 downto 0); -- control alu
        aluShamtOut : OUT std_logic_vector(4 downto 0);  -- control alu
	rs1RegOut : OUT std_logic_vector(4 downto 0); -- to forwarding unit
        rs2RegOut : OUT std_logic_vector(4 downto 0); -- to forwarding unit
        rdRegOut : OUT std_logic_vector(4 downto 0);  -- to forwarding unit
        rf1Out : OUT std_logic_vector(31 downto 0);  -- input of first mux
        pcOut : OUT std_logic_vector(31 downto 0);
        npcOut : OUT std_logic_vector(31 downto 0);
        rf2Out : OUT std_logic_vector(31 downto 0);  -- input of second mux
	immOut : OUT std_logic_vector(31 downto 0);  -- input of second mux
	-- to mem stage (to be further delayed)
	CU_enableOut : OUT std_logic;
        CU_datamem_rwOut : OUT std_logic;
        --CU_pcSrcOut     : out std_logic; -- always 0, 1 if AUIPC
        funct3Out : out std_logic_vector(2 downto 0);
	-- to write back stage (to be further delayed)
	CU_dataSelOut : OUT std_logic;
        CU_write_enableOut : OUT std_logic);
  end component;

  begin

    DUT : idexReg
    port map(clk => clk,
             rst => rst,
             opcodeIn => opcodeIn,
             aluControl => aluControl,
             aluShamt => aluShamt,
             rs1Reg => rs1Reg,
             rs2Reg => rs2Reg,
             rdReg => rdReg,
             rf1 => rf1,
             rf2 => rf2,
             imm => imm,
             pc => pc,
             npc => npc,
             CU_aluSrcIn => CU_aluSrcIn,
             --CU_pcSrcIn => CU_pcSrcIn,
             funct3In => funct3In,
             opcodeOut => opcodeOut,
             CU_enable => CU_enable,
             CU_datamem_rw => CU_datamem_rw,
             CU_write_enable => CU_write_enable,
             CU_dataSel => CU_dataSel,
             aluSrcOut => aluSrcOut,
             aluControlOut => aluControlOut,
             aluShamtOut => aluShamtOut,
             rs1RegOut => rs1RegOut,
             rs2RegOut => rs2RegOut,
             rdRegOut => rdRegOut,
             rf1Out => rf1Out,
             rf2Out => rf2Out,
             pcOut => pcOut,
             npcOut => npcOut,
             immOut => immOut,
             CU_enableOut => CU_enableOut,
             CU_datamem_rwOut => CU_datamem_rwOut,
             funct3Out => funct3Out,
             --CU_pcSrcOut => CU_pcSrcOut,
             CU_dataSelOut => CU_dataSelOut,
             CU_write_enableOut => CU_write_enableOut);

    PCLOCK : process(clk)
    begin
      clk <= not(clk) after 1 ns;
    end process;

    rst <= '1' after 4 ns;
    aluControl <= (others => '1') after 2 ns;
    aluShamt <= (others => '1') after 2 ns;
    memRead <= '1' after 2 ns;
    memWrite <= '1' after 2 ns;
    dataSel <= '1' after 2 ns;
    rs1Reg <= (others => '1') after 2 ns;
    rs2Reg <= (others => '1') after 2 ns;
    rdReg <= (others => '1') after 2 ns;
    rf1 <= (others => '1') after 2 ns;
    rf2 <= (others => '1') after 2 ns;

end test;

configuration CFG_TB_IDEXREG of tbidexReg is
  for test
    for DUT : idexReg
      use configuration WORK.CFG_IDEXREG_STRUCTURAL;
    end for;
  end for;
end CFG_TB_IDEXREG;
