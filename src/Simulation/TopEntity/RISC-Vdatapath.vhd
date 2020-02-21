library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity RISC_VDATAPATH is
  port(clk : IN std_logic;
       rst : IN std_logic;
       fromIRAM : IN std_logic_vector(31 downto 0);
       fromDRAM : IN std_logic_vector(31 downto 0);
       toIRAM : OUT std_logic_vector(31 downto 0);
       toDRAMaddress : OUT std_logic_vector(31 downto 0);
       toDRAMdata : OUT std_logic_vector(31 downto 0);
       toDRAMenable : OUT std_logic;
       toDRAMrw : OUT std_logic;
       toDRAMfunct3 : OUT std_logic_vector(2 downto 0));
end entity;

architecture structural of RISC_VDATAPATH is

  ---------------------------COMPONENTS---------------------------------

  component ifidReg
  port (clk :	IN std_logic;
        rst : IN std_logic;
        pcIn : IN std_logic_vector(31 downto 0);
        pc4In : IN std_logic_vector(31 downto 0);
        instructionIn : IN std_logic_vector(31 downto 0);
        enable : IN std_logic;
        pcOut : OUT std_logic_vector(31 downto 0);
        pc4Out : OUT std_logic_vector(31 downto 0);
        instructionOut : OUT std_logic_vector(31 downto 0));
  end component;

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

  component fetchStage
  port (clk :	IN std_logic;
        rst : IN std_logic;
        enable : IN std_logic;
        pcBranchIn : IN std_logic_vector(31 downto 0);
        imOut : OUT std_logic_vector(31 downto 0);
        pcOut : OUT std_logic_vector(31 downto 0);
        npcOut : OUT std_logic_vector(31 downto 0));
  end component;

  component decodeStage
  port (im_in   : IN std_logic_vector(31 downto 0); -- imOut from fetch stage, istruction memory
        pc_in   : IN std_logic_vector(31 downto 0); -- pcOut from fetch stage, program counter
        npc_in  : IN std_logic_vector(31 downto 0); -- npcOut from fetch stage

        dataWritebackIn : IN std_logic_vector(31 downto 0); -- from data memory, used during loads
        we_in   : IN std_logic; -- from CU, write enable in case of loads or writebacks... must be delayed 3 clk cycles

        clk     : IN std_logic;
        reset   : IN std_logic;

        memReadAluIn : IN std_logic;
        memReadMemIn : IN std_logic;
        --rdAluIn : IN std_logic_vector(4 downto 0); rdAluIn == rdExeIn
        --rdMemIn : IN std_logic_vector(4 downto 0); rdMemIn == rdMemIn sotto
        rdWritebackIn : IN std_logic_vector(4 downto 0); -- rdReg output must be delayed 3 clock cycles, then used as input

        AluExeIn : IN std_logic_vector(31 downto 0);
        AluMemIn : IN std_logic_vector(31 downto 0);
        rdExeIn : IN std_logic_vector(4 downto 0);
        rdMemIn : IN std_logic_vector(4 downto 0);

        pc_out : OUT std_logic_vector(31 downto 0); -- from BDU back to fetch stage

        aluControl : OUT std_logic_vector(4 downto 0); -- to execution stage, to control the ALU
        aluShamt : OUT std_logic_vector(4 downto 0); -- to execution stage, to control the ALU

        rs1Reg  : OUT std_logic_vector(4 downto 0); --to execution stage, used for forwarding
        rs2Reg  : OUT std_logic_vector(4 downto 0); --to execution stage, used for forwarding
        rdReg   : OUT std_logic_vector(4 downto 0); --to execution stage, used for forwarding and must be delayed by 3 clock cycles

        rfoneout : OUT std_logic_vector(31 downto 0); -- to execution stage, rf first output
        rftwoout : OUT std_logic_vector(31 downto 0); -- to execution stage, rf second output
        immout   : OUT std_logic_vector(31 downto 0); -- to execution stage, immediate extender output

        funct3Out : out std_logic_vector(2 downto 0); -- mem stage, to control laods and stores

        hazardOut : out std_logic;

        -- CONTROL UNIT OUTS
        -- execution stage
        CU_aluSrcIn : OUT std_logic_vector(1 downto 0);
        --CU_pcSrcIn     : out std_logic; -- always 0, 1 if AUIPC
        -- memory stage
        CU_enable : OUT std_logic;
        CU_datamem_rw : OUT std_logic;
        -- write back stage
        CU_write_enable : OUT std_logic;
        CU_dataSel : OUT std_logic);
  end component;

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

  component writebackStage
  port (dataSel :	IN std_logic;
        dmemData : IN std_logic_vector(31 downto 0);
        aluData : IN std_logic_vector(31 downto 0);
        wbOut : OUT std_logic_vector(31 downto 0));
  end component;

  ---------------------------SIGNALS------------------------------------

  --opcode signal
  signal opcodeSignal : std_logic_vector(6 downto 0);

  --signals from fetchStage to ifidReg
  signal pcSignal : std_logic_vector(31 downto 0);
  signal npcSignal : std_logic_vector(31 downto 0);
  signal toIRAMsignal : std_logic_vector(31 downto 0);
  signal fromIRAMsignal : std_logic_vector(31 downto 0);

  --signals from idifReg to decodeStage
  signal pcIdSignal, npcIdsignal : std_logic_vector(31 downto 0);
  signal instructionSignal : std_logic_vector(31 downto 0);

  --signal from BDU to fetchStage
  signal BDUpcSignal : std_logic_vector(31 downto 0);

  --signals from decodeStage to idexReg
  signal aluControlSignal :  std_logic_vector(4 downto 0);
  signal aluShamtSignal :  std_logic_vector(4 downto 0);
  signal rs1RegSignal : std_logic_vector(4 downto 0);
  signal rs2RegSignal : std_logic_vector(4 downto 0);
  signal rfoneoutSignal : std_logic_vector(31 downto 0);
  signal rftwooutSignal : std_logic_vector(31 downto 0);
  signal immoutSignal : std_logic_vector(31 downto 0);
  signal CU_aluSrcInSignal : std_logic_vector(1 downto 0);
  signal CU_enableSignal : std_logic;
  signal CU_datamem_rwSignal : std_logic;
  signal funct3 : std_logic_vector(2 downto 0);
  signal CU_write_enableSignal : std_logic;
  signal CU_dataSelSignal : std_logic;

  --signals from idexreg to exstage
  signal rfOneExSignal : std_logic_vector(31 downto 0);
  signal rfTwoExSignal : std_logic_vector(31 downto 0);
  signal immExSignal : std_logic_vector(31 downto 0);
  signal npcExSignal : std_logic_vector(31 downto 0);
  signal aluSrcExSignal : std_logic_vector(1 downto 0);
  signal aluControlExSignal : std_logic_vector(4 downto 0);
  signal aluShamtExSignal : std_logic_vector(4 downto 0);
  signal rsoneExSignal, rstwoExSignal : std_logic_vector(4 downto 0);
  signal aluOutSignal : std_logic_vector(31 downto 0);

  --signals from idexReg to exmemReg
  signal dataSelExSignal : std_logic;
  signal enableExSignal : std_logic;
  signal datamem_rwExSignal : std_logic;
  signal funct3Ex : std_logic_vector(2 downto 0);
  signal write_enableExSignal : std_logic;

  --signals from exmemReg to memwbReg
  signal aluMemSignal : std_logic_vector(31 downto 0);
  signal rfwriteMemSignal : std_logic;

  --signal from exmemReg to DRAM
  signal toDRAMdataSignal : std_logic_vector(31 downto 0);
  signal toDRAMenableSignal : std_logic;
  signal toDRAMrwSignal : std_logic;
  signal toDRAMfunct3Signal : std_logic_vector(2 downto 0);

  --signals from exmemReg to memwbReg
  signal dataSelMemSignal : std_logic;

  --signal from memstage to memwbReg
  signal fromDRAMSig : std_logic_vector(31 downto 0);

  --signals from memwbReg to writebackStage
  signal aluWbSignal : std_logic_vector(31 downto 0);
  signal fromDRAMSignal : std_logic_vector(31 downto 0);

  --signals from writebackStage to RF
  signal dataSelSignal : std_logic;
  signal wbOutSignal : std_logic_vector(31 downto 0);
  signal rfEnableSignal : std_logic;

  --signals that connect the rdRegisters
  signal rdRegIdSignal, rdRegExSignal, rdRegMemSignal, rdRegWbSignal : std_logic_vector(4 downto 0);

  --sigals added for AUIPC support
  signal pcExSignal : std_logic_vector(31 downto 0);
  --signal CU_pcSrcInSignal, pcSrcInExSignal : std_logic;

  --signal enable from HazardDetectionUnit
  signal hazardSignal : std_logic;

  begin

    --output assignment
    toIRAM <= toIRAMsignal;
    fromIRAMsignal <= fromIRAM;
    fromDRAMSig <= fromDRAM;

    toDRAMdata <= toDRAMdataSignal;
    toDRAMaddress <= aluMemSignal;
    toDRAMenable <= toDRAMenableSignal;
    toDRAMrw <= toDRAMrwSignal;
    toDRAMfunct3 <= toDRAMfunct3Signal;

    --fetchStage has to be revisited to handle the npc
    --generation in the decode stage, no BPU will be used
    FETCH : fetchStage
    port map(clk => clk,
             rst => rst,
             enable => hazardSignal,
             pcBranchIn => BDUpcSignal,
             imOut => toIRAMsignal,
             pcOut => pcSignal,
             npcOut => npcSignal);

    IFID : ifidReg
    port map(clk => clk,
             rst => rst,
             pcIn => pcSignal,
             pc4In => npcSignal,
             instructionIn => fromIRAMsignal,
             enable => hazardSignal,
             pcOut => pcIdSignal,
             pc4Out => npcIdsignal,
             instructionOut => instructionSignal);

    --dm_in is the data that comes as input to the RF?
    --if so this data comes from the DMEM and the ALU
    DECODE : decodeStage
    port map(clk => clk,
             reset => rst,
             im_in => instructionSignal,
             pc_in => pcIdSignal,
             npc_in => npcIdsignal,
             dataWritebackIn => wbOutSignal,
             we_in => rfEnableSignal,
             memReadAluIn => datamem_rwExSignal,
             memReadMemIn => toDRAMrwSignal,
             --rdAluIn <= rdRegExSignal,
             --rdMemIn <= rdRegMemSignal,
             rdWritebackIn => rdRegWbSignal,
             AluExeIn => aluOutSignal,
             AluMemIn => aluMemSignal,
             rdExeIn => rdRegExSignal,
             rdMemIn => rdRegMemSignal,
             pc_out => BDUpcSignal,
             aluControl => aluControlSignal,
             aluShamt => aluShamtSignal,
             rs1Reg => rs1RegSignal,
             rs2Reg => rs2RegSignal,
             rdReg => rdRegIdSignal,
             rfoneout => rfoneoutSignal,
             rftwoout => rftwooutSignal,
             immout => immoutSignal,
             funct3Out => funct3,
             hazardOut => hazardSignal,
             CU_aluSrcIn => CU_aluSrcInSignal,
             --CU_pcSrcIn => CU_pcSrcInSignal,
             CU_enable => CU_enableSignal,
             CU_datamem_rw => CU_datamem_rwSignal,
             CU_write_enable => CU_write_enableSignal,
             CU_dataSel => CU_dataSelSignal);

    IDEX : idexReg
    port map(clk => clk,
             rst => rst,
             opcodeIn => instructionSignal(6 downto 0),
             aluControl => aluControlSignal,
             aluShamt => aluShamtSignal,
             rs1Reg => rs1RegSignal,
             rs2Reg => rs2RegSignal,
             rdReg => rdRegIdSignal,
             rf1 => rfoneoutSignal,
             rf2 => rftwooutSignal,
             imm => immoutSignal,
             npc => npcIdsignal,
             pc => pcIdSignal,
             CU_aluSrcIn => CU_aluSrcInSignal,
             --CU_pcSrcIn => CU_pcSrcInSignal,
             CU_enable => CU_enableSignal,
             CU_datamem_rw => CU_datamem_rwSignal,
             funct3In => funct3,
             CU_write_enable => CU_write_enableSignal,
             CU_dataSel => CU_dataSelSignal,
             opcodeOut => opcodeSignal,
             aluSrcOut => aluSrcExSignal,
             aluControlOut => aluControlExSignal,
             aluShamtOut => aluShamtExSignal,
             rs1RegOut => rsoneExSignal,
             rs2RegOut => rstwoExSignal,
             rdRegOut => rdRegExSignal,
             rf1Out => rfOneExSignal,
             npcOut => npcExSignal,
             pcOut => pcExSignal,
             rf2Out => rfTwoExSignal,
             immOut => immExSignal,
             CU_enableOut => enableExSignal,
             CU_datamem_rwOut => datamem_rwExSignal,
             --CU_pcSrcOut => pcSrcInExSignal,
             funct3Out => funct3Ex,
             CU_dataSelOut => dataSelExSignal,
             CU_write_enableOut => write_enableExSignal);

    EXECUTION : executionStage
    port map(opcode => opcodeSignal,
             rfoneIn => rfOneExSignal,
             rftwoIn => rfTwoExSignal,
             immIn => immExSignal,
             npcIn => npcExSignal,
             pcIn => pcExSignal,
             AluForwardedIn => aluMemSignal,
             MemForwardedIn => aluWbSignal,
             aluSrcIn => aluSrcExSignal,
             --pcSrcIn => pcSrcInExSignal,
             aluControlIn => aluControlExSignal,
             aluShamtIn => aluShamtExSignal,
             rsoneIn => rsoneExSignal,
             rstwoIn => rstwoExSignal,
             rdaluIn => rdRegMemSignal,
             rdmemIn => rdRegWbSignal,
             aluOut => aluOutSignal);

    EXMEM : exmemReg
    port map(clk => clk,
             rst => rst,
             memenable => enableExSignal,
             memrw => datamem_rwExSignal,
             memfunct3In => funct3Ex,
             dataSel => dataSelExSignal,
             rdReg => rdRegExSignal,
             aluResult => aluOutSignal,
             rf2Result => rfTwoExSignal,
             rfWrite => write_enableExSignal,
             memenableOut => toDRAMenableSignal,
             memrwOut => toDRAMrwSignal,
             memfunct3Out => toDRAMfunct3Signal,
             dataSelOut => dataSelMemSignal,
             rdRegOut => rdRegMemSignal,
             aluResultOut => aluMemSignal,
             rf2ResultOut => toDRAMdataSignal,
             rfWriteOut => rfwriteMemSignal);

    MEMWB : memwbReg
    port map(clk => clk,
             rst => rst,
             dataSel => dataSelMemSignal,
             dmemData => fromDRAMSig,
             aluData => aluMemSignal,
             rdReg => rdRegMemSignal,
             rfWrite => rfwriteMemSignal,
             dataSelOut => dataSelSignal,
             dmemDataOut => fromDRAMSignal,
             aluDataOut => aluWbSignal,
             rdRegOut => rdRegWbSignal,
             rfWriteOut => rfEnableSignal);

    WRITEBACK : writebackStage
    port map(dataSel => dataSelSignal,
             dmemData => fromDRAMSignal,
             aluData => aluWbSignal,
             wbOut => wbOutSignal);

end structural;

configuration CFG_RISCVDATAPATH_STRUCTURAL of RISC_VDATAPATH is
  for structural
    for all : idexReg
      use configuration WORK.CFG_IDEXREG_STRUCTURAL;
    end for;
    for all : ifidReg
      use configuration WORK.CFG_IFIDREG_STRUCTURAL;
    end for;
    for all : exmemReg
      use configuration WORK.CFG_EXMEMREG_STRUCTURAL;
    end for;
    for all : memwbReg
      use configuration WORK.CFG_MEMWBREG_STRUCTURAL;
    end for;
    for all : fetchStage
      use configuration WORK.CFG_FETCHSTAGE_STRUCTURAL;
    end for;
    for all : decodeStage
      use configuration WORK.CFG_DECODESTAGE_STRUCTURAL;
    end for;
    for all : executionStage
      use configuration WORK.CFG_EXECUTIONSTAGE_STRUCTURAL;
    end for;
    for all : writebackStage
      use configuration WORK.CFG_WRITEBACKSTAGE_STRUCTURAL;
    end for;
  end for;
end configuration;
