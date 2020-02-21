library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all; -- use datamem_vector

entity datamem is
    port (
        clk       : in  STD_LOGIC;
        reset     : in STD_LOGIC; -- active low
        enable    : in std_logic; -- active high

        datamem_address : in  STD_LOGIC_VECTOR (31 downto 0); -- base address (rs1) + offset (imm) computed in ALU
        datamem_datain  : in  STD_LOGIC_VECTOR (31 downto 0); -- rs2, used during store operations
        datamem_negread_write : in std_logic; -- read = 1, write = 0

        funct3  : in std_logic_vector(2 downto 0);

        datamem_dataout : out  STD_LOGIC_VECTOR (31 downto 0));
end entity;

architecture behavioral of datamem is

  signal storage : datamem_storage;
  signal vector : datamem_vector := ( "00001010", "00000000", "00000000", "00000000",
                                      "11010001", "11111111", "11111111", "11111111",
                                      "00010110", "00000000", "00000000", "00000000",
                                      "11111101", "11111111", "11111111", "11111111",
                                      "00001111", "00000000", "00000000", "00000000",
                                      "00011011", "00000000", "00000000", "00000000",
                                      "11111100", "11111111", "11111111", "11111111");
  signal address, addressplusone, addressplustwo, addressplusthree : std_logic_vector(31 downto 0);

begin

  -- address is aligned, so the least significant 2 bits are "00".
  -- Therefore, to access the adjacent addresses, no addition is required.
  address <= datamem_address;
  addressplusone <= address(31 downto 2) & "01";
  addressplustwo <= address(31 downto 2) & "10";
  addressplusthree <= address(31 downto 2) & "11";

	datamem_proc: process (clk)
		variable add, add1, add2, add3 : integer;
	begin
		if (clk'event and clk = '1') then
			if reset = '0' then
				-- keep output on high impedance
				datamem_dataout <= (others => 'Z');

				-- erase data memory content and load vector v in data memory
				for j in 0 to to_integer(unsigned(vector_start_address))-1 loop
				  storage(j) <= (others => '0');
				end loop;

        -- load vector v
        for i in 0 to vector_length-1 loop
          storage(to_integer(unsigned(vector_start_address))+i) <= vector(i);
        end loop;

        for k in to_integer(unsigned(vector_end_address)) to datamem_length-1 loop
          storage(k) <= (others => '0');
        end loop;

      elsif (enable = '0') then
        datamem_dataout <= (others => 'Z');

      elsif (datamem_negread_write = '1' and enable = '1') then
			add := to_integer(unsigned(address));
  			add1 := to_integer(unsigned(addressplusone));
  			add2 := to_integer(unsigned(addressplustwo));
  			add3 := to_integer(unsigned(addressplusthree));
          -- read operation => LOAD
          case funct3 is
            when "000" => datamem_dataout(7 downto 0) <= storage(add); -- LB: load byte on least significant 8 bits
                        datamem_dataout(31 downto 8) <= (others => storage(add)(7)); -- LB: the most significant 24 bits are sign extended

            when "001" =>  datamem_dataout(7 downto 0) <= storage(add); -- LH: load byte on least significant 16 bits
                        datamem_dataout(15 downto 8) <= storage(add1);
                        datamem_dataout(31 downto 16) <= (others => storage(add1)(7)); -- LH: the most significant 16 bits are sign extended
                        -- NOTICE THAT DATA IS ORGANIZED IN LITTLE ENDIAN STYLE
            when "010" =>  datamem_dataout(7 downto 0) <= storage(add); -- LW: return 32 bits
                        datamem_dataout(15 downto 8) <= storage(add1);
                        datamem_dataout(23 downto 16) <= storage(add2);
                        datamem_dataout(31 downto 24) <= storage(add3);
                        -- NOTICE THAT DATA IS ORGANIZED IN LITTLE ENDIAN STYLE
            when "100" =>
                          datamem_dataout(7 downto 0) <= storage(add); -- LBU: load byte on least significant 8 bits
                          datamem_dataout(31 downto 8) <= (others => '0'); -- LBU: the most significant 24 bits are set to zero

            when "101" => datamem_dataout(7 downto 0) <= storage(add); -- LHU: load byte on least significant 16 bits
                          datamem_dataout(15 downto 8) <= storage(add1);
                          datamem_dataout(31 downto 16) <= (others => '0'); -- LHU: the most significant 16 bits are set to zero

            when others => datamem_dataout <= (others => 'Z');
          end case;

      elsif (datamem_negread_write = '0' and enable = '1') then
			-- keep output on high impedance
				datamem_dataout <= (others => 'Z');
          -- write operation => STORE
				add := to_integer(unsigned(address));
  				add1 := to_integer(unsigned(addressplusone));
  				add2 := to_integer(unsigned(addressplustwo));
  				add3 := to_integer(unsigned(addressplusthree));
          case funct3 is
            -- SB
            when "000" =>  storage(add) <= datamem_datain(7 downto 0);
            -- SH
            when "001" =>  storage(add1) <= datamem_datain(15 downto 8);
                        storage(add) <= datamem_datain(7 downto 0);
            -- SW
            when "010" =>  storage(add3) <= datamem_datain(31 downto 24);
                        storage(add2) <= datamem_datain(23 downto 16);
                        storage(add1) <= datamem_datain(15 downto 8);
                        storage(add) <= datamem_datain(7 downto 0);

            when others => datamem_dataout <= (others => 'Z');
          end case;
      end if;
    end if;
	end process;

end architecture;

configuration CFG_DATAMEM_BEHAVIORAL of datamem is
  for behavioral
  end for;
end configuration;
