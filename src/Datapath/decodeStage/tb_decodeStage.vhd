library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity tbdecodeStage is
end entity;

architecture test of tbdecodeStage is

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

	signal im_in_s, dataWritebackIn_s, pc_out_s, rfoneout_s, rftwoout_s, imm_out_s, AluExeIn_s, AluMemIn_s : std_logic_vector(31 downto 0);
	signal pc_in_s : std_logic_vector(31 downto 0);
	signal npc_in_s : std_logic_vector(31 downto 0);
	signal aluControl_s, aluShamt_s, rs1Reg_s, rs2Reg_s, rdReg_s, rdWritebackIn_s, rdExeIn_s, rdMemIn_s : std_logic_vector(4 downto 0);
	signal rst_s, memReadAluIn_s, memReadMemIn_s, hazardOut_s : std_logic;
  --signal CU_pcSrcIn_s : std_logic;
	signal clk_s : std_logic := '1';
  signal funct3Out_s : std_logic_vector (2 downto 0);

	signal CU_aluSrcIn_s: std_logic_vector (1 downto 0);
	signal CU_enable_s,  CU_datamem_rw_s, CU_write_enable_s, CU_dataSel_s : std_logic;

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

  signal we0_s, we1_s, we2_s : std_logic;

begin

  DUT : decodeStage port map(
          im_in   => im_in_s, -- imOut from fetch stage, istruction memory
          pc_in   => pc_in_s, -- pcOut from fetch stage, program counter
          npc_in  => npc_in_s, -- npcOut from fetch stage
          dataWritebackIn => dataWritebackIn_s, -- from data memory, used during loads
          we_in   => we2_s,
          clk     => clk_s,
          reset   => rst_s,
          memReadAluIn => memReadAluIn_s,
          memReadMemIn => memReadMemIn_s,
          rdWritebackIn => rdWritebackIn_s,
          AluExeIn => AluExeIn_s,
          AluMemIn => AluMemIn_s,
          rdExeIn => rdExeIn_s,
          rdMemIn => rdMemIn_s,
          pc_out => pc_out_s,
          aluControl => aluControl_s,
          aluShamt => aluShamt_s,
          rs1Reg  => rs1Reg_s,
          rs2Reg  => rs2Reg_s,
          rdReg   => rdReg_s, -- ok
          rfoneout => rfoneout_s,
          rftwoout => rftwoout_s,
          immout   => imm_out_s,
          funct3Out => funct3Out_s,
          hazardOut => hazardOut_s,
          CU_aluSrcIn => CU_aluSrcIn_s,
          --CU_pcSrcIn => CU_pcSrcIn_s,
          CU_enable => CU_enable_s,
          CU_datamem_rw => CU_datamem_rw_s,  -- ok
          CU_write_enable => CU_write_enable_s,
          CU_dataSel => CU_dataSel_s);

  -- HDU feedback
    -- take output "CU_datamem_rw_s" of CU, delay it by one and two clock cycles

    REGEXEHAZARD : FD
    port map(CU_datamem_rw_s, clk_s, rst_s, memReadAluIn_s);

    REGMEMHAZARD : FD
    port map(memReadAluIn_s, clk_s, rst_s, memReadMemIn_s);

  -----------------

  RDREGEXE : REGISTER_GENERIC
  generic map (5)
  port map(rdReg_s, clk_s, rst_s, rdExeIn_s);

  RDREGMEM : REGISTER_GENERIC
  generic map (5)
  port map(rdExeIn_s, clk_s, rst_s, rdMemIn_s);

  RDREGWB : REGISTER_GENERIC
  generic map (5)
  port map(rdMemIn_s, clk_s, rst_s, rdWritebackIn_s);



  --------------
  -- CU write enable delayed 3 clock cycles
  REG0_WE : FD
  port map(CU_write_enable_s, clk_s, rst_s, we0_s);
  REG1_WE : FD
  port map(we0_s, clk_s, rst_s, we1_s);
  REG2_WE : FD
  port map(we1_s, clk_s, rst_s, we2_s);

    PCLOCK : process(clk_s)
    begin
      clk_s <= not(clk_s) after 1 ns;
    end process;

	Program_Counter : process(clk_s, rst_s)
  begin
    if rst_s = '0' then
      pc_in_s <= (others => 'Z');
      npc_in_s <= (others => 'Z');
    elsif (rst_s'event and rst_s = '1') then
      pc_in_s <= "00000000000000000000000000000000"; -- 0
      npc_in_s <= "00000000000000000000000000000100"; -- 4
		elsif (clk_s'event and clk_s = '1') then
			pc_in_s <= pc_out_s;
			npc_in_s <= std_logic_vector(to_unsigned((to_integer(unsigned(pc_out_s)) + 4), 32));
		end if;
  end process;



	rst_s <= '0', '1' after 3 ns;
--	im_in_s <=  "01100110000000000000000000000000",            -- ADD R0, R0, R0 = NOP
--              "00100110000100000001000000010000" after 3 ns, -- ADDI R1, R1, 16
--              "01100110001100000010000010000000" after 5 ns; -- ADD R3, R2, R1 = hazard RAW

  im_in_s <=  "00000000000000000000000000010011",            -- ADDI R0, R0, 0 = NOP
              "00000000000000000000000000010011" after 4 ns, -- NOP
              "00000000000000000000000000010011" after 6 ns, -- NOP
              "00000000000000000000000000010011" after 7 ns, -- NOP
              "00000000000000000000000000010011" after 10 ns, -- NOP
              "00000000000100010001100001100011" after 12 ns, -- BNE R1, R2, 16 = NOT TAKEN
              --"00000000000100010000000110110011" after 13 ns, -- ADD R3, R2, R1 = hazard RAW? NO!
              "00000000101000000000000110010011" after 14 ns,
              "00000110010000101000110001100011" after 16 ns, -- BEQ R4, R5, 120 = TAKEN
              "00000000000000000000000000010011" after 18 ns; -- NOP
  AluExeIn_s <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ", "00111111111111111111111111111111" after 3 ns;
  AluMemIn_s <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ", "00111111111111111111111111111111" after 3 ns;

-- I expect that the first branch is not taken, that no hazard is detected after the branch and
-- that the second branch is taken

-------------------------------------------------------------------------------
--------------------------- PROF PROGRAMM -------------------------------------
-------------------------------------------------------------------------------

--    im_in_s <=  "000000000‭11100000000100000010011‬" ,
--                "00001111110000010000001000010111" after 3 ns,‬
--                "11111111110000100000001000010011"
--                "00001111110000010000001010010111"
--                "00000001000000101000001010010011"
                -- "01000000000000000000011010110111"
                -- "11111111111101101000011010010011"
                -- "00000010000010000000100001100011"
                -- "00000000000000100010010000000011"
                -- "01000001111101000101010010010011"
                -- "00000000100101000100010100110011"
                -- "00000000000101001111010010010011"
                -- "00000000100101010000010100110011"
                -- "00000000010000100000001000010011"
                -- "11111111111110000000100000010011"
                -- "00000000110101010010010110110011"
                -- "11111100000001011000111011100011"
                -- "00000000000001010000011010110011"
                -- "11111101010111111111000011101111"
                -- "00000000110100101010000000100011"
                -- "00000000000000000000000011101111"
                -- "00000000000000000000000000010011"


end architecture;

configuration CFG_TB_DECODESTAGE of tbdecodeStage is
  for test
    for DUT : decodeStage
      use configuration WORK.CFG_DECODESTAGE_STRUCTURAL;
    end for;
  end for;
end CFG_TB_DECODESTAGE;
