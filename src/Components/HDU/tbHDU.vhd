library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.define.all;

entity TB_HDU is
end TB_HDU;

architecture TEST of TB_HDU is

	signal	rsoneIn, rstwoIn, rdAluIn : std_logic_vector(4 downto 0) := "00000";
  signal rdMemIn : std_logic_vector(4 downto 0) := "11111";
  signal memReadAluIn, memReadMemIn : std_logic := '1';
  signal hazardOut : std_logic;
	signal rst : std_logic := '1';

	component HDU
	port (rst : IN std_logic;
				memReadAluIn : IN std_logic;
        memReadMemIn : IN std_logic;
        rdAluIn : IN std_logic_vector(4 downto 0);
        rdMemIn : IN std_logic_vector(4 downto 0);
        rsOneIn : IN std_logic_vector(4 downto 0);
        rsTwoIn : IN std_logic_vector(4 downto 0);
        hazardOut : OUT std_logic);
	end component;

begin

	U1 : HDU
	port map(rst, memReadAluIn, memReadMemIn, rdAluIn, rdMemIn, rsOneIn, rsTwoIn, hazardOut);

  memReadAluIn <= '0' after 10 ns;
	memReadMemIn <= '0' after 20 ns;
  rsOneIn <= "00001" after 12 ns, "00000" after 16 ns;
  rsTwoIn <= "00001" after 20 ns;
  rdAluIn <= "00001" after 11 ns, "11111" after 20 ns;
  rdMemIn <= "00000" after 21 ns, "00001" after 25 ns;

end TEST;

configuration CFG_TB_HDU of TB_HDU is
   for TEST
      for U1: HDU
         use configuration WORK.CFG_HDU_BEHAVIORAL;
      end for;
   end for;
end CFG_TB_HDU;
