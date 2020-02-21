library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use WORK.globals.all;
use WORK.define.all;

entity RISC_V is
  port(clk : IN std_logic;
       rst : IN std_logic);
end entity;

architecture structural of RISC_V is

  component IRAM
  generic(RAM_DEPTH : integer := RAM_DEPTH;
          I_SIZE : integer := I_SIZE);
  port(Rst  : in  std_logic;
       Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
       Dout : out std_logic_vector(I_SIZE - 1 downto 0));
  end component;

  component datamem
  port (
      clk       : in  STD_LOGIC;
      reset     : in STD_LOGIC; -- active low
      enable    : in std_logic; -- active high

      datamem_address : in  STD_LOGIC_VECTOR (31 downto 0); -- base address (rs1) + offset (imm) computed in ALU
      datamem_datain  : in  STD_LOGIC_VECTOR (31 downto 0); -- rs2, used during store operations
      datamem_negread_write : in std_logic; -- read = 0, write = 1

      funct3  : in std_logic_vector(2 downto 0);

      datamem_dataout : out  STD_LOGIC_VECTOR (31 downto 0));
  end component;

  component RISC_VDATAPATH
  port(clk : IN std_logic;
       rst : IN std_logic;
       fromIRAM : IN std_logic_vector(31 downto 0);
       fromDRAM : IN std_logic_vector(31 downto 0);
       toIRAM : OUT std_logic_vector(31 downto 0);
       toDRAMaddress : OUT std_logic_vector(31 downto 0);
       toDRAMdata : OUT std_logic_vector(31 downto 0);
       toDRAMenable : OUT std_logic;
       toDRAMrw : OUT std_logic;
       toDRAMfunct3 : OUT std_logic_vector(2 downto 0));
  end component;

  --signals to connect datapath with IRAM and DMEM
  signal fromIRAMsignal, fromDRAMSignal, toIRAMsignal, toDRAMaddressSignal, toDRAMdataSignal : std_logic_vector(31 downto 0);
  signal toDRAMenableSignal, toDRAMrwSignal : std_logic;
  signal toDRAMfunct3Signal : std_logic_vector(2 downto 0);

  begin

  DATAPATHINST : RISC_VDATAPATH
  port map(clk => clk,
           rst => rst,
           fromIRAM => fromIRAMsignal,
           fromDRAM => fromDRAMSignal,
           toIRAM => toIRAMsignal,
           toDRAMaddress => toDRAMaddressSignal,
           toDRAMdata => toDRAMdataSignal,
           toDRAMenable => toDRAMenableSignal,
           toDRAMrw => toDRAMrwSignal,
           toDRAMfunct3 => toDRAMfunct3Signal);

  DRAMINST : datamem
  port map(clk => clk,
           reset => rst,
           enable => toDRAMenableSignal,
           datamem_address => toDRAMaddressSignal,
           datamem_datain => toDRAMdataSignal,
           datamem_negread_write => toDRAMrwSignal,
           funct3 => toDRAMfunct3Signal,
           datamem_dataout => fromDRAMSignal);

  IRAMINST : IRAM
  generic map(RAM_DEPTH, I_SIZE)
  port map(rst => rst,
           Addr => toIRAMsignal,
           Dout => fromIRAMsignal);

end structural;

configuration CFG_RISCV_STRUCTURAL of RISC_V is
  for structural
    for all : IRAM
      use configuration WORK.CFG_IRAM_BEHAVIORAL;
    end for;
    for all : datamem
      use configuration WORK.CFG_DATAMEM_BEHAVIORAL;
    end for;
    for all : RISC_VDATAPATH
      use configuration WORK.CFG_RISCVDATAPATH_STRUCTURAL;
    end for;
  end for;
end configuration;
