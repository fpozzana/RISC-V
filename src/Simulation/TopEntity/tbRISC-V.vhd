library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity tbRISC_V is
end tbRISC_V;

architecture test of tbRISC_V is

  signal clk, rst : std_logic := '0';

  component RISC_V
  port(clk : IN std_logic;
       rst : IN std_logic);
  end component;

  begin

    DUT : RISC_V
    port map(clk => clk,
             rst => rst);

    rst <= '1' after 5 ns;

    PCLOCK : process(clk)
    begin
      clk <= not(clk) after 1 ns;
    end process;

end test;

configuration CFG_TB_RISC_V of tbRISC_V is
  for test
    for DUT : RISC_V
      use configuration WORK.CFG_RISCV_STRUCTURAL;
    end for;
  end for;
end CFG_TB_RISC_V;
