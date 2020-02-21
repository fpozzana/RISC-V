--test : tested OK, the component works as expected
--clocked write, non clocked read
--as soon as the input is ready the read process gives the value of the REGISTERS
--if there is a conflict between read and write address the write input
--is bypassed to the output and the right register is read during the leading
--edge of a clock cycle

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity REGISTER_FILE is
  generic (numBit_data : integer := NumBitData;
	         numBit_address : integer := NumBitAddress;
	         numBit_registers : integer := NumBitRegisterFile);
  port (CK :	IN std_logic;
        Reset : IN std_logic;
	      Write_enable : IN std_logic;
	      Write_address : IN std_logic_vector(numBit_address-1 downto 0);
 	      Read_one_address :	IN std_logic_vector(numBit_address-1 downto 0);
 	      Read_two_address : IN std_logic_vector(numBit_address-1 downto 0);
 	      Data_in : IN std_logic_vector(numBit_data-1 downto 0);
        Data_one_out :	OUT std_logic_vector(numBit_data-1 downto 0);
 	      Data_two_out :	OUT std_logic_vector(numBit_data-1 downto 0));
end REGISTER_FILE;

architecture BEHAVIORAL of REGISTER_FILE is

	type REG_ARRAY is array(numBit_registers-1 downto 0) of std_logic_vector(numBit_data-1 downto 0);
	signal REGISTERS : REG_ARRAY := (others => (others => '0')); --initialize my registers to 0

  begin
    write : process(CK,Reset,Write_enable,Write_address,Data_in)
      begin
        if(Reset = '0') then
          REGISTERS <= (others => (others => '0'));
        elsif(CK'event and CK = '1' and Write_enable = '1') then
          if(not(to_integer(unsigned(Write_address)) = 0)) then
            REGISTERS(to_integer(unsigned(Write_address))) <= Data_in;
          end if;
        end if;
      end process;

    read : process (Read_one_address, Read_two_address,Write_enable,Data_in,Write_address)
	   begin
      if (Write_enable = '1' and Read_one_address = Write_address and Read_two_address = Write_address) then
        if(not(to_integer(unsigned(Write_address)) = 0)) then
          data_one_out <= Data_in;
          data_two_out <= Data_in;
        elsif(to_integer(unsigned(Write_address)) = 0) then
          data_one_out <= REGISTERS(to_integer(unsigned(Read_one_address)));
          data_two_out <= REGISTERS(to_integer(unsigned(Read_two_address)));
        end if;
      elsif(Write_enable = '1' and Read_one_address = Write_address) then
         if(not(to_integer(unsigned(Write_address)) = 0)) then
           data_one_out <= Data_in;
           data_two_out <= REGISTERS(to_integer(unsigned(Read_two_address)));
         elsif(to_integer(unsigned(Write_address)) = 0) then
           data_one_out <= REGISTERS(to_integer(unsigned(Read_one_address)));
           data_two_out <= REGISTERS(to_integer(unsigned(Read_two_address)));
         end if;
      elsif(Write_enable = '1' and Read_two_address = Write_address) then
        if(not(to_integer(unsigned(Write_address)) = 0)) then
          data_two_out <= Data_in;
          data_one_out <= REGISTERS(to_integer(unsigned(Read_one_address)));
        elsif(to_integer(unsigned(Write_address)) = 0) then
          data_one_out <= REGISTERS(to_integer(unsigned(Read_one_address)));
          data_two_out <= REGISTERS(to_integer(unsigned(Read_two_address)));
        end if;
      else
        data_one_out <= REGISTERS(to_integer(unsigned(Read_one_address)));
        data_two_out <= REGISTERS(to_integer(unsigned(Read_two_address)));
      end if;
     end process;
   end BEHAVIORAL;

configuration CFG_REGISTER_FILE_BEHAVIORAL of REGISTER_FILE is
  for BEHAVIORAL
  end for;
end configuration;
