library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity idexReg is
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
end idexReg;

architecture structural of idexReg is
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

    RS1REGISTER : REGISTER_GENERIC
    generic map(5)
    port map(rs1Reg, clk, rst, rs1RegOut);

    RS2REGISTER : REGISTER_GENERIC
    generic map(5)
    port map(rs2Reg, clk, rst, rs2RegOut);

    RDREGISTER : REGISTER_GENERIC
    generic map(5)
    port map(rdReg, clk, rst, rdRegOut);

    RF1REGISTER : REGISTER_GENERIC
    generic map(32)
    port map(rf1, clk, rst, rf1Out);

    OPCODEREG : REGISTER_GENERIC
    generic map(7)
    port map(opcodeIn, clk, rst, opcodeOut);

    RF2REGISTER : REGISTER_GENERIC
    generic map(32)
    port map(rf2, clk, rst, rf2Out);

    PCREGISTER : REGISTER_GENERIC
    generic map(32)
    port map(pc, clk, rst, pcOut);

    NPCREGISTER : REGISTER_GENERIC
    generic map(32)
    port map(npc, clk, rst, npcOut);

    IMMREGISTER : REGISTER_GENERIC
    generic map(32)
    port map(imm, clk, rst, immOut);

    ALUCONTROLREGISTER : REGISTER_GENERIC
    generic map(5)
    port map(aluControl, clk, rst, aluControlOut);

    ALUSHAMTREGISTER : REGISTER_GENERIC
    generic map(5)
    port map(aluShamt, clk, rst, aluShamtOut);

    DATASELREG : FD
    port map(CU_dataSel, clk, rst, CU_dataSelOut);

    MEMREADWRITEREG : FD
    port map(CU_datamem_rw, clk, rst, CU_datamem_rwOut);

    MEMENABLEREG : FD
    port map(CU_enable, clk, rst, CU_enableOut);

    RFWRITEENABLEREG : FD
    port map(CU_write_enable, clk, rst, CU_write_enableOut);

    ALUSRCREG : REGISTER_GENERIC
    generic map(2)
    port map(CU_aluSrcIn, clk, rst, aluSrcOut);

    ENTRYSIZEREG: REGISTER_GENERIC
    generic map(3)
    port map(funct3In, clk, rst, funct3Out);

    --PCSRCINREG : FD
    --port map(CU_pcSrcIn, clk, rst, CU_pcSrcOut);


end structural;

configuration CFG_IDEXREG_STRUCTURAL of idexReg is
  for structural
    for all : FD
      use configuration WORK.CFG_FD_SYNC;
    end for;
    for all : REGISTER_GENERIC
      use configuration WORK.CFG_REGISTER_GENERIC_STRUCTURAL_SYNC;
    end for;
  end for;
end configuration;
