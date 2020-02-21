library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity decodeStage is
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
end decodeStage;

architecture structural of decodeStage is

  component REGISTER_FILE
    generic (numBit_data : integer := 64;
  	         numBit_address : integer := 5;
  	         numBit_registers : integer := 32);
    port (CK :	IN std_logic;
          Reset : IN std_logic;
  	      Write_enable : IN std_logic;
  	      Write_address : IN std_logic_vector(numBit_address-1 downto 0);
   	      Read_one_address :	IN std_logic_vector(numBit_address-1 downto 0);
   	      Read_two_address : IN std_logic_vector(numBit_address-1 downto 0);
   	      Data_in : IN std_logic_vector(numBit_data-1 downto 0);
          Data_one_out :	OUT std_logic_vector(numBit_data-1 downto 0);
   	      Data_two_out :	OUT std_logic_vector(numBit_data-1 downto 0));
  end component;

  component BDU
    port (opcode  : IN  std_logic_vector(6 downto 0);
          funct3  : IN  std_logic_vector(2 downto 0);
          rs1Reg  : IN  std_logic_vector(4 downto 0);
          rs2Reg  : IN  std_logic_vector(4 downto 0);
          rfoneout : IN  std_logic_vector(31 downto 0);
          rftwoout : IN  std_logic_vector(31 downto 0);
          pc      : IN  std_logic_vector(31 downto 0);
          npc     : IN  std_logic_vector(31 downto 0);
          offset  : IN  std_logic_vector(31 downto 0);
          AluExeIn : IN std_logic_vector(31 downto 0);
          AluMemIn : IN std_logic_vector(31 downto 0);
          rdExeIn : IN std_logic_vector(4 downto 0);
          rdMemIn : IN std_logic_vector(4 downto 0);  -- confronta con rs branch
          pc_out  : OUT std_logic_vector(31 downto 0));
  end component;

  component IMMEXTENDER
    port (opcode : IN std_logic_vector(6 downto 0);
          I_imm : IN std_logic_vector(11 downto 0);
          S_imm : IN std_logic_vector(11 downto 0);
          SB_imm : IN std_logic_vector(11 downto 0);
          U_imm : IN std_logic_vector(19 downto 0);
          UJ_imm : IN std_logic_vector(19 downto 0);
          ImmediateOut : OUT std_logic_vector(31 downto 0));
  end component;

  component controlUnit
    port(
      clk         : in std_logic;
      reset       : in std_logic;
      opcode      : in std_logic_vector(6 downto 0);
      hazardIn    : in std_logic;
      -- execution stage
      aluSrcIn    : out std_logic_vector(1 downto 0);
      --pcSrcIn     : out std_logic; -- always 0, 1 if AUIPC
      -- memory stage
      enable      : out std_logic;
      datamem_rw  : out std_logic;
      -- write back stage
      write_enable : out std_logic;
      dataSel :	out std_logic );
  end component;

  component  ALUCONTROLLER is
    port (opcode : IN std_logic_vector(6 downto 0);
          func3 : IN std_logic_vector(2 downto 0);
          hazardIn : In std_logic;
          direction : IN std_logic;
          shamt : IN std_logic_vector(4 downto 0);
          aluControl : OUT std_logic_vector(4 downto 0);
          aluShamt : OUT std_logic_vector(4 downto 0));
  end component;

  component HDU
   port (rst : IN std_logic;
         memReadAluIn : IN std_logic;
         memReadMemIn : IN std_logic;
         rdAluIn : IN std_logic_vector(4 downto 0);
         rdMemIn : IN std_logic_vector(4 downto 0);
         rsOneIn : IN std_logic_vector(4 downto 0);
         rsTwoIn : IN std_logic_vector(4 downto 0);
         hazardOut : OUT std_logic);
 end component;

  signal S_imm_s : std_logic_vector(11 downto 0);
  signal SB_imm_s : std_logic_vector(11 downto 0);
  signal UJ_imm_s : std_logic_vector(19 downto 0);

  signal hazardOut_s : std_logic;

  signal rfoneout_s, rftwoout_s, immout_s: std_logic_vector(31 downto 0);
begin
    RF: REGISTER_FILE   generic map ( numBit_data  => 32,
    	                                numBit_address => 5,
    	                                numBit_registers => 32)
                        port map    ( CK => clk,
                                      Reset => reset,
                              	      Write_enable => we_in, -- write enable comes from CU and must be delayed 3 clock cycles
                              	      Write_address => rdWritebackIn,  -- the write address is delayed 3 clock cycles
                               	      Read_one_address => im_in(19 downto 15),
                               	      Read_two_address => im_in(24 downto 20),
                               	      Data_in => dataWritebackIn,
                                      Data_one_out => rfoneout_s,
                               	      Data_two_out => rftwoout_s);

    rfoneout <= rfoneout_s;
    rftwoout <= rftwoout_s;

    BDU_inst : BDU port map(  opcode => im_in(6 downto 0),
                              funct3 => im_in(14 downto 12),
                              rs1Reg => im_in(19 downto 15),
                              rs2Reg => im_in(24 downto 20),
                              rfoneout => rfoneout_s,
                              rftwoout => rftwoout_s,
                              pc      => pc_in,
                              npc     => npc_in,
                              offset  => immout_s,
                              AluExeIn => AluExeIn,
                              AluMemIn => AluMemIn,
                              rdExeIn => rdExeIn,
                              rdMemIn => rdMemIn,
                              pc_out  => pc_out);


    S_imm_s <= im_in(31 downto 25) & im_in(11 downto 7);
    SB_imm_s <= im_in(31) & im_in(7) & im_in(30 downto 25) & im_in(11 downto 8);
    UJ_imm_s <= im_in(31) & im_in(19 downto 12) & im_in(20) & im_in(30 downto 21);

    IMMEXT: IMMEXTENDER port map (  opcode => im_in(6 downto 0),
                                    I_imm => im_in(31 downto 20),
                                    S_imm => S_imm_s,
                                    SB_imm => SB_imm_s,
                                    U_imm => im_in(31 downto 12),
                                    UJ_imm => UJ_imm_s,
                                    ImmediateOut => immout_s);
    immout <= immout_s;

    rdReg <= im_in(11 downto 7);
    rs1Reg <= im_in(19 downto 15);
    rs2Reg <= im_in(24 downto 20);

    ALUCONTR: ALUCONTROLLER port map (opcode => im_in(6 downto 0),
                                      func3 => im_in(14 downto 12),
                                      hazardIn => hazardOut_s,
                                      direction => im_in(30),
                                      shamt => im_in(24 downto 20),
                                      aluControl => aluControl,
                                      aluShamt => aluShamt);

    CU : controlUnit port map ( clk => clk,
                                reset => reset,
                                opcode => im_in(6 downto 0),
                                hazardIn => hazardOut_s,
                                aluSrcIn => CU_aluSrcIn,
                                --pcSrcIn  => CU_pcSrcIn,
                                enable => CU_enable,
                                datamem_rw => CU_datamem_rw,
                                write_enable => CU_write_enable,
                                dataSel => CU_dataSel);

    HazardDetectionUnit : HDU port map( rst => reset,
                                        memReadAluIn => memReadAluIn,
                                        memReadMemIn => memReadMemIn,
                                        rdAluIn => rdExeIn,
                                        rdMemIn => rdMemIn,
                                        rsOneIn => im_in(19 downto 15),
                                        rsTwoIn => im_in(24 downto 20),
                                        hazardOut => hazardOut_s);
    hazardOut <= hazardOut_s;
    funct3Out <= im_in(14 downto 12);


end structural;

configuration CFG_DECODESTAGE_STRUCTURAL of decodeStage is
  for structural
    for all : ALUCONTROLLER
      use configuration WORK.CFG_ALUCONTROLLER_BEHAVIORAL;
    end for;
    for all : REGISTER_FILE
      use configuration WORK.CFG_REGISTER_FILE_BEHAVIORAL;
    end for;
    for all : controlUnit
      use configuration WORK.CFG_CONTROLUNIT_BEHAVIORAL;
    end for;
    for all : IMMEXTENDER
      use configuration WORK.CFG_IMMEXTENDER_BEHAVIORAL;
    end for;
    for all : BDU
      use configuration WORK.CFG_BDU_BEHAVIORAL;
    end for;
  end for;
end configuration;
