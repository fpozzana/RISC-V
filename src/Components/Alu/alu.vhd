library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;

entity ALU is
  port (op : IN std_logic_vector(4 downto 0);
        operand_a : IN std_logic_vector(31 downto 0);
        operand_b : IN std_logic_vector(31 downto 0);
        operand_shamt : IN std_logic_vector(4 downto 0);
        aluOut: OUT std_logic_vector(31 downto 0));
end ALU;

architecture BEHAVIORAL of ALU is

	constant plus_one : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";

  begin

    ALU_PROCESS : process (op, operand_a, operand_b, operand_shamt)
    begin
      case op is
         when "00000" => aluOut <= std_logic_vector(shift_right(signed(operand_a), to_integer(unsigned(operand_shamt))));                --SRAI
         --when "00001" => aluOut <= std_logic_vector(shift_left(signed(operand_a), to_integer(unsigned(operand_shamt))));                   --SLLI
         --when "00010" => aluOut <= std_logic_vector(shift_right(signed(operand_a), to_integer(unsigned(operand_shamt))));                  --SRLI
         --when "00011" => aluOut <= std_logic_vector(shift_right(unsigned(operand_a), to_integer(unsigned(operand_b(4 downto 0)))));        --SRA
         --when "00100" => aluOut <= std_logic_vector(shift_left(signed(operand_a), to_integer(unsigned(operand_b(4 downto 0)))));           --SLL
         --when "00101" => aluOut <= std_logic_vector(shift_right(signed(operand_a), to_integer(unsigned(operand_b(4 downto 0)))));          --SRL
	       when "00110" 	=> aluOut <= (operand_a + operand_b);                                                                              --ADD
         --when "00111" 	=> aluOut <= (operand_a - operand_b);                                                                              --SUB
         when "01000" 	=> aluOut <= (operand_a AND operand_b);                                                                            --AND
	       --when "01001" 	=> aluOut <= (operand_a OR operand_b);                                                                             --OR
	       when "01010" 	=> aluOut <= (operand_a XOR operand_b);                                                                            --XOR
	       --when "01011" 	=> if(unsigned(operand_a) = unsigned(operand_b)) then                                                              --SEQ
				   --                aluOut <= "00000000000000000000000000000001";
            --             else
				      --             aluOut <= (others => '0');
			          --         end if;
         --when "01100" 	=> if(unsigned(operand_a) /= unsigned(operand_b)) then                                                             --SNE
				   --                aluOut <= "00000000000000000000000000000001";
            --             else
				      --             aluOut <= "00000000000000000000000000000000";
			          --         end if;
         when "01101" 	=> if(signed(operand_a) < signed(operand_b)) then                                                                  --SLT
				                   aluOut <= "00000000000000000000000000000001";
                         else
				                   aluOut <= "00000000000000000000000000000000";
			                   end if;
         --when "01110" 	=> if(signed(operand_a) >= signed(operand_b)) then                                                                 --SGE
				   --                aluOut <= "00000000000000000000000000000001";
            --             else
				      --             aluOut <= "00000000000000000000000000000000";
			          --         end if;
        --when "01111" 	=> if(unsigned(operand_a) < unsigned(operand_b)) then                                                                --SLTU
          --                 aluOut <= "00000000000000000000000000000001";
            --              else
              --             aluOut <= "00000000000000000000000000000000";
                --         end if;
        --when "10000" 	=> if(signed(operand_a) >= signed(operand_b)) then                                                                   --SGEU
          --                 aluOut <= "00000000000000000000000000000001";
            --             else
              --             aluOut <= "00000000000000000000000000000000";
                --         end if;
        --when "10001" => aluOut <= operand_a + plus_four;                                                                                   --JAL and JALR
        when "10001" => aluOut <= operand_a;                                                                                               --JAL and JALR
        when "10010" => aluOut <= operand_b;                                                                                               --LUI
        when "10011" => aluOut <= "00000000000000000000000000000000";                                                                      --no operation
        --when "10100" => if(operand_a(31) = '0') then
          --                aluOut <= operand_a;
            --            else
              --            aluOut <= not (operand_a) + plus_one;
                --        end if;
        when others => null;
      end case;
    end process ALU_PROCESS;

  end BEHAVIORAL;

configuration CFG_ALU_BEHAVIORAL of ALU is
  for BEHAVIORAL
  end for;
end CFG_ALU_BEHAVIORAL;
