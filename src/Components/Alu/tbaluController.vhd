library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity TB_ALUCONTROLLER is
end TB_ALUCONTROLLER;

architecture TEST of TB_ALUCONTROLLER is

	--signal opcode : std_logic_vector(6 downto 0) := (others => '0');
	signal opcode : std_logic_vector(6 downto 0) := I_TYPE;
	signal func3 : std_logic_vector(2 downto 0) := (others => '0');
  signal direction : std_logic := '1';
  signal shamt : std_logic_vector(4 downto 0) := "00000";
  signal aluControl : std_logic_vector(4 downto 0);
  signal aluShamt : std_logic_vector(4 downto 0);
	signal hazardIn_s : std_logic := '0';

	component ALUCONTROLLER is
  port (opcode : IN std_logic_vector(6 downto 0);
        func3 : IN std_logic_vector(2 downto 0);
        hazardIn : In std_logic;
        direction : IN std_logic;
        shamt : IN std_logic_vector(4 downto 0);
        aluControl : OUT std_logic_vector(4 downto 0);
        aluShamt : OUT std_logic_vector(4 downto 0));
	end component;

begin

	U1 : ALUCONTROLLER
	port map(opcode, func3, hazardIn_s, direction, shamt, aluControl, aluShamt);

  --process is
    --begin
    --for i in 0 to 128 loop
    	--	wait for 5 ns;
        --opcode <= std_logic_vector(unsigned(opcode) + "00001");
    		--for j in 0 to 7 loop
          --wait for 5 ns;
          --func3 <= std_logic_vector(unsigned(func3) + "001");
        --end loop;
    --end loop;
  --end process;

end TEST;

configuration CFG_TB_ALUCONTROLLER of TB_ALUCONTROLLER is
   for TEST
      for U1: ALUCONTROLLER
         use configuration WORK.CFG_ALUCONTROLLER_BEHAVIORAL;
      end for;
   end for;
end CFG_TB_ALUCONTROLLER;
