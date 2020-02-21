--combinational component to be placed in the decode stage
--it decodes the instruction and create accordingly the alu control signals

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity ALUCONTROLLER is
  port (opcode : IN std_logic_vector(6 downto 0);
        func3 : IN std_logic_vector(2 downto 0);
        hazardIn : In std_logic;
        direction : IN std_logic;
        shamt : IN std_logic_vector(4 downto 0);
        aluControl : OUT std_logic_vector(4 downto 0);
        aluShamt : OUT std_logic_vector(4 downto 0));
end ALUCONTROLLER;

architecture BEHAVIORAL of ALUCONTROLLER is

  begin

    aluShamt <= shamt;    --shift amount is fed directly to the alu, depending on aluControl it will be used or not

    ALUCONTROLLER_PROCESS : process (opcode, func3, direction)
    begin
      if hazardIn = '1' then -- HAZARD!!!
        aluControl <= "10011"; -- NOP
      else
        -- NO HAZARD, LET'S SEE WHICH OPERATION TO EXECUTE
        if opcode = R_TYPE then
          case func3 is
            when FUNC3_ADD =>   if direction = '0' then
                                  aluControl <= "00110";
                                else
                                  aluControl <= "00111";
                                end if;
            --when FUNC3_SLL => aluControl <= "00100";
            when FUNC3_SLT => aluControl <= "01101";
            --when FUNC3_SLTU => aluControl <= "01111";
            when FUNC3_XOR => aluControl <= "01010";
            when FUNC3_SRL =>   if direction = '0' then
                                  aluControl <= "00101";
                                else
                                  aluControl <= "00011";
                                end if;
            --when FUNC3_OR => aluControl <= "01001";
            when FUNC3_AND => aluControl <= "01000";
            when others => aluControl <= "10011"; -- NOP
          end case;
        elsif opcode = I_TYPE then
          case func3 is

            when FUNC3_ADDI => aluControl <= "00110";
            when FUNC3_SLTI => aluControl <= "01101";
            --when FUNC3_SLTIU => aluControl <= "01111";
            when FUNC3_XORI => aluControl <= "01010";
            --when FUNC3_ORI => aluControl <= "01001";
            when FUNC3_ANDI => aluControl <= "01000";
            --when FUNC3_SLLI => aluControl <= "00001";
            when FUNC3_SRLI =>  if direction = '0' then
                                  aluControl <= "00010";
                                else
                                  aluControl <= "00000";
                                end if;
            when others => aluControl <= "10011"; -- NOP
          end case;
        elsif opcode = I_TYPE_LOAD then
          case func3 is
            --when FUNC3_LB => aluControl <= "00110";
            --when FUNC3_LH => aluControl <= "00110";
            when FUNC3_LW => aluControl <= "00110";
            --when FUNC3_LBU => aluControl <= "00110";
            --when FUNC3_LHU => aluControl <= "00110";
            when others => aluControl <= "10011"; -- NOP
          end case;
        elsif opcode = S_TYPE then
          case func3 is
            --when FUNC3_SB => aluControl <= "00110";
            --when FUNC3_SH => aluControl <= "00110";
            when FUNC3_SW => aluControl <= "00110";
            when others => aluControl <= "10011"; -- NOP
          end case;
        --elsif opcode = SB_TYPE then
          --if func3 = FUNC3_BEQ then
            --aluControl <= "01011";
          --elsif func3 = FUNC3_BNE then
            --aluControl <= "01100";
          --elsif func3 = FUNC3_BLT then
            --aluControl <= "01101";
          --elsif func3 = FUNC3_BGE then
            --aluControl <= "01110";
          --elsif func3 = FUNC3_BLTU then
            --aluControl <= "01111";
          --elsif func3 = FUNC3_BGEU then
            --aluControl <= "10000";
          --end if;
        elsif opcode = SB_TYPE then
          aluControl <= "10011";
        elsif opcode = UJ_TYPE_JAL then
          aluControl <= "10001";
        --elsif opcode = UJ_TYPE_JALR then
          --aluControl <= "10001";
        elsif opcode = U_TYPE_LUI then
          aluControl <= "10010";
        elsif opcode = U_TYPE_AUIPC then
          aluControl <= "00110";
        --elsif opcode = I_TYPE_ABS then
          --aluControl <= "10100";
        else
          aluControl <= "10011"; -- NOP
        end if;
      end if;
    end process ALUCONTROLLER_PROCESS;

  end BEHAVIORAL;

configuration CFG_ALUCONTROLLER_BEHAVIORAL of ALUCONTROLLER is
  for BEHAVIORAL
  end for;
end CFG_ALUCONTROLLER_BEHAVIORAL;
