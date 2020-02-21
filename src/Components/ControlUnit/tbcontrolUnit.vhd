library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity TB_CONTROLUNIT is
end TB_CONTROLUNIT;

architecture TEST of TB_CONTROLUNIT is

	signal clk : std_logic := '0';
  signal reset : std_logic := '0';
  signal opcode : std_logic_vector(6 downto 0);
  signal hazardIn : std_logic := '0';
  signal aluSrcIn : std_logic_vector(1 downto 0);
  signal enable, datamem_rw, write_enable, dataSel : std_logic;

	component controlUnit
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
	end component;

begin

	U1 : controlUnit
	port map(clk, reset, opcode, hazardIn, aluSrcIn, enable, datamem_rw, write_enable, dataSel);

  opcode <= SB_TYPE, UJ_TYPE_JAL after 30 ns, UJ_TYPE_JALR after 40 ns, "0000000" after 50 ns;
  hazardIn <= '1' after 25 ns;
  reset <= '1' after 3 ns;

  PCLOCK : process(clk)
  begin
    clk <= not(clk) after 1 ns;
  end process;

end TEST;

configuration CFG_TB_CONTROLUNIT of TB_CONTROLUNIT is
   for TEST
      for U1: controlUnit
         use configuration WORK.CFG_CONTROLUNIT_BEHAVIORAL;
      end for;
   end for;
end CFG_TB_CONTROLUNIT;
