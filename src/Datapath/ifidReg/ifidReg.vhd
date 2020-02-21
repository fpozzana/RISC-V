library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity ifidReg is
  port (clk :	IN std_logic;
        rst : IN std_logic;
        pcIn : IN std_logic_vector(31 downto 0);
        pc4In : IN std_logic_vector(31 downto 0);
        instructionIn : IN std_logic_vector(31 downto 0);
        enable : IN std_logic;
        pcOut : OUT std_logic_vector(31 downto 0);
        pc4Out : OUT std_logic_vector(31 downto 0);
        instructionOut : OUT std_logic_vector(31 downto 0));
end ifidReg;

architecture structural of ifidReg is
  component REGISTER_ENABLE
  generic (NBIT : integer := NumBitRegister);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    ENABLE : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  begin

    PCREGISTER : REGISTER_ENABLE
    generic map(32)
    port map(pcIn, clk, enable, rst, pcOut);

    --pcOut <= pcIn;

    PC4REGISTER : REGISTER_ENABLE
    generic map(32)
    port map(pc4In, clk, enable, rst, pc4Out);

    --pc4Out <= pc4In;

    INSTRUCTIONREGISTER : REGISTER_ENABLE
    generic map(32)
    port map(instructionIn, clk, enable, rst, instructionOut);

end structural;

configuration CFG_IFIDREG_STRUCTURAL of ifidReg is
  for structural
    for all : REGISTER_ENABLE
      use configuration WORK.CFG_REGISTER_ENABLE;
    end for;
  end for;
end configuration;
