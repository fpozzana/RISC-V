-- BPU : BRANCH DETECTION UNIT
-- To support jump and branch operations in a pipelined procesor, three apporaches are possible:
-- 1) flush the pipeline and put stalls
-- 2) anticipate the jump/branch evaluation, to fluch and insert fewer stalls (BDU)
-- 3) use banch prediction table (BPU)

-- This unit implements the second strategy (branch DETECTION unit, BDU).

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.define.all;
use WORK.globals.all;

entity BDU is
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
end entity;

architecture BEHAVIORAL of BDU is
  signal data1, data2 : std_logic_vector(31 downto 0);
begin

  BDU_PROC : process (rs1Reg, rs2Reg, AluExeIn, AluMemIn, rdExeIn, rdMemIn, rfoneout, rftwoout)
  -- Inside the sensitivity list there is also rs1, rs2, programm counter.
  -- Suppose there are two adjacent branches: if they have the same
  -- opcode and func3, but different rs1 and rs2, the second branch
  -- is executed correctly. The pc is there just in case.
  begin
    if rs1Reg = rdExeIn then
      data1 <= AluExeIn;
    elsif rs1Reg = rdMemIn then
      data1 <= AluMemIn;
    else
      data1 <= rfoneout;
    end if;

    if rs2Reg = rdExeIn then
      data2 <= AluExeIn;
    elsif rs2Reg = rdMemIn then
      data2 <= AluMemIn;
    else
      data2 <= rftwoout;
    end if;

    end process BDU_PROC;

    BDU_PROC_2 : process (data2, data1, opcode, funct3, pc, npc, offset)
    begin

    case opcode is
      when SB_TYPE =>
        case funct3 is
          -- BEQ
          when FUNC3_BEQ => if(unsigned(data1) = unsigned(data2)) then                                                              --SEQ
                        pc_out <= pc + offset;
                      else
                        pc_out <= npc;
                      end if;
          --BNE
          when FUNC3_BNE => if(unsigned(data1) /= unsigned(data2)) then                                                              --SEQ
                        pc_out <= pc + offset;
                      else
                        pc_out <= npc;
                      end if;
          --BLT
          when FUNC3_BLT => if(signed(data1) < signed(data2)) then                                                              --SEQ
                        pc_out <= pc + offset;
                      else
                        pc_out <= npc;
                      end if;
          --BGE
          when FUNC3_BGE => if(signed(data1) >= signed(data2)) then                                                              --SEQ
                        pc_out <= pc + offset;
                      else
                        pc_out <= npc;
                      end if;
          --BLTU
          when FUNC3_BLTU => if(unsigned(data1) < unsigned(data2)) then                                                              --SEQ
                        pc_out <= pc + offset;
                      else
                        pc_out <= npc;
                      end if;
          --BGEU
          when FUNC3_BGEU => if(unsigned(data1) >= unsigned(data2)) then                                                              --SEQ
                        pc_out <= pc + offset;
                      else
                        pc_out <= npc;
                      end if;
          when others => pc_out <= npc;

        end case;
      -- JAL
      when UJ_TYPE_JAL => pc_out <= pc + offset;
      -- JALR
      when UJ_TYPE_JALR => pc_out <= pc + offset;
      when others => pc_out <= npc;

    end case;
end process BDU_PROC_2;

  end BEHAVIORAL;

configuration CFG_BDU_BEHAVIORAL of BDU is
  for BEHAVIORAL
  end for;
end CFG_BDU_BEHAVIORAL;
