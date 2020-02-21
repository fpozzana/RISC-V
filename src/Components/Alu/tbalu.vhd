library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;

entity TB_ALU is
end TB_ALU;

architecture TEST of TB_ALU is

	signal	op : std_logic_vector(4 downto 0) := "00000";
	signal	operand_a :	std_logic_vector(31 downto 0);
	signal	operand_b : std_logic_vector(31 downto 0);
  signal operand_shamt : std_logic_vector(4 downto 0);
	signal	aluOut : std_logic_vector(31 downto 0);

	component ALU
  port (op : IN std_logic_vector(4 downto 0);
        operand_a : IN std_logic_vector(31 downto 0);
        operand_b : IN std_logic_vector(31 downto 0);
        operand_shamt : IN std_logic_vector(4 downto 0);
        aluOut: OUT std_logic_vector(31 downto 0));
	end component;

begin

	U1 : ALU
	port map(op, operand_a, operand_b, operand_shamt, aluOut);

  operand_a <= "11111111111111111111111111111101", "10000000000000000000000000000111" after 20 ns;
  operand_b <= "00000000000000000000000000000001";
  operand_shamt <= "11111";
  op <= "00000"; -- SRAI
  -- process is
  --   begin
  --   for i in 0 to 18 loop
  --   		wait for 5 ns;
  --       op <= std_logic_vector(unsigned(op) + "00001");
  --   		wait for 5 ns;
  --   end loop;
  -- end process;

end TEST;

configuration CFG_TB_ALU of TB_ALU is
   for TEST
      for U1: ALU
         use configuration WORK.CFG_ALU_BEHAVIORAL;
      end for;
   end for;
end CFG_TB_ALU;
