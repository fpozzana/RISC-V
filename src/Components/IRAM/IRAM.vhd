library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use WORK.define.all;
use WORK.globals.all;


entity IRAM is
  generic(RAM_DEPTH : integer := RAM_DEPTH;
          I_SIZE : integer := I_SIZE);
  port(Rst  : in  std_logic;
       Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
       Dout : out std_logic_vector(I_SIZE - 1 downto 0));
end IRAM;

architecture IRam_Bhe of IRAM is

  type RAMtype is array (0 to RAM_DEPTH - 1) of integer;
  signal IRAM_mem : RAMtype;
  signal RealAddress : std_logic_vector(31 downto 0);

begin

  Dout <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(RealAddress))),I_SIZE);


  --check of the IRAM bound
  IRAM_PROC : process(Addr)
    begin
      if((unsigned(Addr)) < RAM_DEPTH) then
        RealAddress <= Addr;
      end if;
  end process;

  FILL_MEM_P: process (Rst)
  file mem_fp: text ;
  variable file_line : line;
  variable index : integer := 0;
  variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
  begin
    if (Rst = '0') then
      --file_open(mem_fp,"C:/Users/franc/Documents/GitHub/RISC_V_lite/Components/IRAM/asm/asm_test/asm.hex",READ_MODE);
      file_open(mem_fp,"C:/Users/FEDERICO/Desktop/git_projects/RISC_V_lite/Components/IRAM/asm/asm_test/asm.hex",READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        IRAM_mem(index) <= conv_integer(unsigned(tmp_data_u));
        index := index + 1;
      end loop;
    end if;
  end process FILL_MEM_P;

end IRam_Bhe;

configuration CFG_IRAM_BEHAVIORAL of IRAM is
	for IRam_Bhe
	end for;
end CFG_IRAM_BEHAVIORAL;
