library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.define.all;

entity TB_IMMEXTENDER is
end TB_IMMEXTENDER;

architecture TEST of TB_IMMEXTENDER is

	signal	opcode : std_logic_vector(6 downto 0) := "0000000";
	signal	I_imm, S_imm, SB_imm :	std_logic_vector(11 downto 0);
	signal	U_imm, UJ_imm : std_logic_vector(19 downto 0);
  signal ImmediateOut : std_logic_vector(31 downto 0);

	component IMMEXTENDER
  port (opcode : IN std_logic_vector(6 downto 0);
        I_imm : IN std_logic_vector(11 downto 0);
        S_imm : IN std_logic_vector(11 downto 0);
        SB_imm : IN std_logic_vector(11 downto 0);
        U_imm : IN std_logic_vector(19 downto 0);
        UJ_imm : IN std_logic_vector(19 downto 0);
        ImmediateOut : OUT std_logic_vector(31 downto 0));
	end component;

begin

	U1 : IMMEXTENDER
	port map(opcode, I_imm, S_imm, SB_imm, U_imm, UJ_imm, ImmediateOut);

  I_imm <= "000000000001";
  S_imm <= "000000000001";
  SB_imm <= "000000000001";
  U_imm <= "00000000000000000001";
  UJ_imm <= "00000000000000000001";

  opcode <= I_TYPE, S_TYPE after 5 ns, I_TYPE_LOAD after 10 ns, SB_TYPE after 15 ns, U_TYPE_LUI after 20 ns, UJ_TYPE_JAL after 25 ns, U_TYPE_AUIPC after 30 ns, UJ_TYPE_JALR after 35 ns, "1101100" after 40 ns;

end TEST;

configuration CFG_TB_IMMEXTENDER of TB_IMMEXTENDER is
   for TEST
      for U1: IMMEXTENDER
         use configuration WORK.CFG_IMMEXTENDER_BEHAVIORAL;
      end for;
   end for;
end CFG_TB_IMMEXTENDER;
