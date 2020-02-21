library ieee;
use ieee.std_logic_1164.all;

package define is
  --constants used by the alu controller to feed the proper signals to the alu
  --the following encoding are compatible with the RV32I instruction set
  constant R_TYPE : std_logic_vector(6 downto 0) := "0110011";
  constant I_TYPE : std_logic_vector(6 downto 0) := "0010011";
  constant I_TYPE_LOAD : std_logic_vector(6 downto 0) := "0000011";
  constant S_TYPE : std_logic_vector(6 downto 0) := "0100011";
  constant SB_TYPE : std_logic_vector(6 downto 0) := "1100011";
  constant U_TYPE_LUI : std_logic_vector(6 downto 0) := "0110111";
  constant U_TYPE_AUIPC : std_logic_vector(6 downto 0) := "0010111";
  constant UJ_TYPE_JAL : std_logic_vector(6 downto 0) := "1101111";
  constant UJ_TYPE_JALR : std_logic_vector(6 downto 0) := "1100111";
  constant I_TYPE_ABS : std_logic_vector(6 downto 0) := "1111111";

  constant FUNC3_JALR : std_logic_vector(2 downto 0) := "000";
  constant FUNC3_BEQ : std_logic_vector(2 downto 0) := "000";
  constant FUNC3_BNE : std_logic_vector(2 downto 0) := "001";
  constant FUNC3_BLT : std_logic_vector(2 downto 0) := "100";
  constant FUNC3_BGE : std_logic_vector(2 downto 0) := "101";
  constant FUNC3_BLTU : std_logic_vector(2 downto 0) := "110";
  constant FUNC3_BGEU : std_logic_vector(2 downto 0) := "111";
  constant FUNC3_LB : std_logic_vector(2 downto 0) := "000";
  constant FUNC3_LH : std_logic_vector(2 downto 0) := "001";
  constant FUNC3_LW : std_logic_vector(2 downto 0) := "010";
  constant FUNC3_LBU : std_logic_vector(2 downto 0) := "100";
  constant FUNC3_LHU : std_logic_vector(2 downto 0) := "101";
  constant FUNC3_SB : std_logic_vector(2 downto 0) := "000";
  constant FUNC3_SH : std_logic_vector(2 downto 0) := "001";
  constant FUNC3_SW : std_logic_vector(2 downto 0) := "010";
  constant FUNC3_ADDI : std_logic_vector(2 downto 0) := "000";
  constant FUNC3_SLTI : std_logic_vector(2 downto 0) := "010";
  constant FUNC3_SLTIU : std_logic_vector(2 downto 0) := "011";
  constant FUNC3_XORI : std_logic_vector(2 downto 0) := "100";
  constant FUNC3_ORI : std_logic_vector(2 downto 0) := "110";
  constant FUNC3_ANDI : std_logic_vector(2 downto 0) := "111";
  constant FUNC3_SLLI : std_logic_vector(2 downto 0) := "001";
  constant FUNC3_SRLI : std_logic_vector(2 downto 0) := "101";
  constant FUNC3_SRAI : std_logic_vector(2 downto 0) := "101";
  constant FUNC3_ADD : std_logic_vector(2 downto 0) := "000";
  constant FUNC3_SUB : std_logic_vector(2 downto 0) := "000";
  constant FUNC3_SLL : std_logic_vector(2 downto 0) := "001";
  constant FUNC3_SLT : std_logic_vector(2 downto 0) := "010";
  constant FUNC3_SLTU : std_logic_vector(2 downto 0) := "011";
  constant FUNC3_XOR : std_logic_vector(2 downto 0) := "100";
  constant FUNC3_SRL : std_logic_vector(2 downto 0) := "101";
  constant FUNC3_SRA : std_logic_vector(2 downto 0) := "101";
  constant FUNC3_OR : std_logic_vector(2 downto 0) := "110";
  constant FUNC3_AND : std_logic_vector(2 downto 0) := "111";

end define;
