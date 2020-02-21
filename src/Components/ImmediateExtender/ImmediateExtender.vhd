library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.define.all;

entity IMMEXTENDER is
  port (opcode : IN std_logic_vector(6 downto 0);
        I_imm : IN std_logic_vector(11 downto 0);
        S_imm : IN std_logic_vector(11 downto 0);
        SB_imm : IN std_logic_vector(11 downto 0);
        U_imm : IN std_logic_vector(19 downto 0);
        UJ_imm : IN std_logic_vector(19 downto 0);
        ImmediateOut : OUT std_logic_vector(31 downto 0));
end IMMEXTENDER;

architecture BEHAVIORAL of IMMEXTENDER is

  begin

    IMM_PROCESS : process (opcode, I_imm, S_imm, SB_imm, U_imm, UJ_imm)
    begin
      case opcode is
         when I_TYPE  => if(I_imm(11) = '0') then
                           ImmediateOut <= "00000000000000000000" & I_imm;
                         elsif(I_imm(11) = '1') then
                           ImmediateOut <= "11111111111111111111" & I_imm;
                         end if;
         when I_TYPE_LOAD  => if(I_imm(11) = '0') then
                                ImmediateOut <= "00000000000000000000" & I_imm;
                              elsif(I_imm(11) = '1') then
                                ImmediateOut <= "11111111111111111111" & I_imm;
                              end if;
        when S_TYPE  => if(S_imm(11) = '0') then
                          ImmediateOut <= "00000000000000000000" & S_imm;
                        elsif(S_imm(11) = '1') then
                          ImmediateOut <= "11111111111111111111" & S_imm;
                        end if;
        when SB_TYPE  => if(SB_imm(11) = '0') then
                           ImmediateOut <= "0000000000000000000" & SB_imm & '0';
                         elsif(SB_imm(11) = '1') then
                           ImmediateOut <= "1111111111111111111" & SB_imm & '0';
                         end if;
       when U_TYPE_LUI  => ImmediateOut <= U_imm & "000000000000";

       when U_TYPE_AUIPC  => ImmediateOut <= U_imm & "000000000000";
                             --if(U_imm(19) = '0') then
                               --ImmediateOut <= "000000000000" & U_imm;
                             --elsif(U_imm(19) = '1') then
                               --ImmediateOut <= "111111111111" & U_imm;
                             --end if;
       when UJ_TYPE_JAL  => if(UJ_imm(19) = '0') then
                              ImmediateOut <= "00000000000" & UJ_imm & '0';
                            elsif(UJ_imm(19) = '1') then
                              ImmediateOut <= "11111111111" & UJ_imm & '0';
                            end if;
       when UJ_TYPE_JALR  => if(I_imm(11) = '0') then
                               ImmediateOut <= "00000000000000000000" & I_imm;
                             elsif(I_imm(11) = '1') then
                               ImmediateOut <= "11111111111111111111" & I_imm;
                             end if;
	      when others => ImmediateOut <= (others => '0');
      end case;
    end process IMM_PROCESS;

  end BEHAVIORAL;

configuration CFG_IMMEXTENDER_BEHAVIORAL of IMMEXTENDER is
  for BEHAVIORAL
  end for;
end CFG_IMMEXTENDER_BEHAVIORAL;
