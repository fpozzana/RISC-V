library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use WORK.globals.all;

entity TB_IRAM is
end TB_IRAM;

architecture TEST of TB_IRAM is
  constant NBIT : integer := I_SIZE;
  signal reset : std_logic := '1';
  signal address : std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal dout : std_logic_vector(NBIT-1 downto 0);

  component IRAM
  generic(RAM_DEPTH : integer := RAM_DEPTH;
          I_SIZE : integer := I_SIZE);
  port(Rst  : in  std_logic;
       Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
       Dout : out std_logic_vector(I_SIZE - 1 downto 0));
  end component;

  begin
    DUT : IRAM
    generic map(RAM_DEPTH,NBIT)
    port map(reset,address,dout);

    reset <= '0' after 4 ns;

    test: process
    begin
    wait for 2 ns;
    NumROW : for i in 0 to RAM_DEPTH loop
      wait for 10 ns ;
	    address <= address + '1';
    end loop NumROW ;
    end process test;

end TEST;

configuration CFG_TB_IRAM of TB_IRAM is
  for TEST
    for DUT : IRAM
      use configuration WORK.CFG_IRAM_BEHAVIORAL;
    end for;
  end for;
end CFG_TB_IRAM;
