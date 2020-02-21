library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity controlUnit is
    port(
        clk         : in std_logic;
        reset       : in std_logic;
        opcode      : in std_logic_vector(6 downto 0);
        hazardIn    : in std_logic;
        -- execution stage
        aluSrcIn    : out std_logic_vector(1 downto 0);
        --pcSrcIn     : out std_logic; -- always 0, 1 if AUIPC
        -- memory stage
        enable      : out std_logic;
        datamem_rw  : out std_logic;
        -- write back stage
        write_enable : out std_logic;
        dataSel :	out std_logic );
end entity;

architecture behavioural of controlUnit is
  --type state_type is (state_0, state_1, state_2);
  --signal present_state: state_type := state_0;

  -- NB: the majority of instructions do not access the Data memory (no read or write).
  -- Therefore the enable output of the CU that controls the data memory is off.
  -- The value assumed by datamem_rw of the CU does not matter in these situations.
  -- To simplify the HDU design, for all instructions (except for loads) datamem_rw
  -- is set of WRITE; since enable is off it does not matter.

  -- The HDU must understand if a load is followed by an operation that wants to access
  -- the destination register of the load: if true, it must stall the pipeline and
  -- stop the fecth stage for one clock cycle (to not loose the operation = re-fetch).

  --read is 1, write is 0

begin

    cw_selection : process (opcode)
    begin
      if hazardIn = '0' then -- no hazard
        case opcode is
          when R_TYPE =>        aluSrcIn <= "00"; -- take rfone and rftwo as input for alu
                                --pcSrcIn  <= '1';
                                write_enable <= '1'; -- write back the result in RF
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- skip data memory

          when I_TYPE =>        --aluSrcIn <= "10"; -- take rfone and immediate as inputs for alu
                                aluSrcIn <= "10"; -- take rfone and immediate as inputs for alu
                                --pcSrcIn  <= '1';
                                write_enable <= '1'; -- write the result in RF
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- skip data memory

          when I_TYPE_LOAD =>   aluSrcIn <= "10";
                                --pcSrcIn  <= '1';
                                write_enable <= '1';
                                enable <= '1'; -- load operation must read on data memory
                                datamem_rw <= '1'; -- read data memory
                                dataSel <= '1'; -- select data memory output

          when S_TYPE =>        aluSrcIn <= "10"; -- PLEASE CHECK!!!!!!!!
                                --pcSrcIn  <= '1';
                                write_enable <= '0'; -- store operations do not save anything back in RF
                                enable <= '1'; -- need to write data memory
                                datamem_rw <= '0'; -- write data memory
                                dataSel <= '0'; -- does not matter, we = 0

          when SB_TYPE =>       aluSrcIn <= "11"; -- take npc and immediate
                                --pcSrcIn  <= '1';
                                write_enable <= '0'; -- branch operation do not write back in RF
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- does not matter

          -- LUI = load upper immediate: basically we save in a temporary register
          -- an extension of the jump address, to reach further destinations. It is always
          -- followed by JALR. The store in temporary register is done in decode stage, so
          -- the entire CU is useless
          when U_TYPE_LUI =>    aluSrcIn <= "10"; -- bit 0 doesn't matter, bit 1 immediate
                                --pcSrcIn  <= '1';
                                write_enable <= '0';
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- does not matter

          -- I think this operation is not yet supported and requires a special hnadling
          -- in datapath. For now, CU is left empty
          when U_TYPE_AUIPC =>  aluSrcIn <= "11"; -- pc + offset
                                --pcSrcIn  <= '1';
                                write_enable <= '1';
                                enable <= '0';
                                datamem_rw <= '0';
                                dataSel <= '0';

          when UJ_TYPE_JAL =>   aluSrcIn <= "00"; -- doesn't matter
                                --pcSrcIn  <= '1';
                                write_enable <= '0'; -- no need to write back in RF
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- does not matter

          when UJ_TYPE_JALR =>  aluSrcIn <= "00"; -- doesn't matter
                                --pcSrcIn  <= '1';
                                write_enable <= '0'; -- no need to write back in RF
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- does not matter

          when I_TYPE_ABS => --aluSrcIn <= "10"; -- take rfone and immediate as inputs for alu
                                aluSrcIn <= "10"; -- take rfone and immediate as inputs for alu
                                --pcSrcIn  <= '1';
                                write_enable <= '1'; -- write the result in RF
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- skip data memory

          when others =>        aluSrcIn <= "00"; -- doesn't matter
                                --pcSrcIn  <= '1';
                                write_enable <= '0'; -- no need to write back in RF
                                enable <= '0'; -- no need to read/write data memory
                                datamem_rw <= '0'; -- does not matter, enable = 0
                                dataSel <= '0'; -- does not matter
        end case;

      else -- hazard!!!
        aluSrcIn <= "00";
        --pcSrcIn  <= '1';
        write_enable <= '0'; -- make sure we don'y write anything in RF
        enable <= '0'; -- no need to read/write data memory
        datamem_rw <= '0'; -- does not matter, enable = 0
        dataSel <= '0'; -- does not matter
      end if;
    end process;
  end behavioural;

configuration CFG_CONTROLUNIT_BEHAVIORAL of controlUnit is
  for behavioural
  end for;
end CFG_CONTROLUNIT_BEHAVIORAL;
