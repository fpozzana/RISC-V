library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity tbifidReg is
end tbifidReg;

architecture test of tbifidReg is
  signal pcIn, pc4In, instructionIn : std_logic_vector(31 downto 0) := (others => '1');
  signal pcOut, pc4Out, instructionOut : std_logic_vector(31 downto 0);
  signal clk, rst : std_logic := '0';
  signal enable : std_logic := '1';

  component ifidReg
  port (clk :	IN std_logic;
        rst : IN std_logic;
        pcIn : IN std_logic_vector(31 downto 0);
        pc4In : IN std_logic_vector(31 downto 0);
        instructionIn : IN std_logic_vector(31 downto 0);
        enable : IN std_logic;
        pcOut : OUT std_logic_vector(31 downto 0);
        pc4Out : OUT std_logic_vector(31 downto 0);
        instructionOut : OUT std_logic_vector(31 downto 0));
  end component;

  begin

    DUT : ifidReg
    port map(clk => clk,
             rst => rst,
             pcIn => pcIn,
             pc4In => pc4In,
             instructionIn => instructionIn,
             enable => enable,
             pcOut => pcOut,
             pc4Out => pc4Out,
             instructionOut => instructionOut);

    PCLOCK : process(clk)
    begin
      clk <= not(clk) after 1 ns;
    end process;

    rst <= '1' after 5 ns;
    enable <= '0' after 11 ns;

end test;

configuration CFG_TB_IFIDREG of tbifidReg is
  for test
    for DUT : ifidReg
      use configuration WORK.CFG_IFIDREG_STRUCTURAL;
    end for;
  end for;
end CFG_TB_IFIDREG;
