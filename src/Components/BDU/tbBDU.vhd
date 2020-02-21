library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity TB_BDU is
end TB_BDU;

architecture TEST of TB_BDU is

	signal opcode : std_logic_vector(6 downto 0);
  signal funct3 : std_logic_vector(2 downto 0);
  signal rfoneout, rftwoout, pc, npc, offset, pc_out, AluExeIn, AluMemIn : std_logic_vector(31 downto 0);
	signal rs1Reg, rs2Reg, rdExeIn, rdMemIn : std_logic_vector(4 downto 0);

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

begin

	U1 : BDU
	port map(opcode, funct3, rs1Reg, rs2Reg, rfoneout, rftwoout, pc, npc, offset, AluExeIn, AluMemIn, rdExeIn, rdMemIn, pc_out);

  rfoneout <= "00000000000000000000000000000000";
  rftwoout <= "00000000000000000000000000000000";

	rs1Reg <= "00000";
	rs2Reg <= "00001";

	rdExeIn <= "11111", "10101" after 70 ns, (others => '1') after 75 ns;
	rdMemIn <= "11111", "10101" after 75 ns, (others => '1') after 80 ns;

	AluExeIn <= (others => '1');
	AluMemIn <= (others => '1');

  pc <= "00000000000000000000000000011100";
  npc <= "00000000000000000000000000100000";

  offset <= "00000000000000000000000011110000";

  opcode <= SB_TYPE, UJ_TYPE_JAL after 30 ns, UJ_TYPE_JALR after 40 ns, "0000000" after 50 ns;
  funct3 <= FUNC3_BEQ, FUNC3_BNE after 5 ns, FUNC3_BLT after 10 ns, FUNC3_BGE after 15 ns, FUNC3_BLTU after 20 ns, FUNC3_BGEU after 25 ns;


end TEST;

configuration CFG_TB_BDU of TB_BDU is
   for TEST
      for U1: BDU
         use configuration WORK.CFG_BDU_BEHAVIORAL;
      end for;
   end for;
end CFG_TB_BDU;
