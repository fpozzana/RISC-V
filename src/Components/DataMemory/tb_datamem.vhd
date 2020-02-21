library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity tb_datamem is
end entity;

architecture test of tb_datamem is
  signal clk_s : std_logic := '1';
  signal rst_s, enable_s : std_logic ;
  signal address_s, datain_s : std_logic_vector(31 downto 0) := (others => '0');
  signal funct3_s : std_logic_vector(2 downto 0) := (others => '0');
  signal rw_s : std_logic := '1';
  signal dataout_s : std_logic_vector(31 downto 0);

  component datamem is
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

  begin

    DUT : datamem
    port map(clk => clk_s,
             reset => rst_s,
             enable => enable_s,
             datamem_address => address_s,
             datamem_datain => datain_s,
             datamem_negread_write => rw_s,
             funct3 => funct3_s,
             datamem_dataout => dataout_s );

    PCLOCK : process(clk_s)
    begin
      clk_s <= not(clk_s) after 1 ns;
    end process;


	----------------------- LW test -------------------------------------------
--    rst_s <= '1' after 5 ns;  -- reset active low
--    enable_s <= '1' after 7 ns; -- enable active high, at 7 ns the simulation begins

--	  funct3_s <= "010";

--    address_s <= "00000000000000000000000000000000", "00000000000000000000000000000100" after 13 ns; -- remeber to keep addresses aligned!!
--    datain_s <= "00011000000000000000000000001110", "01111000000000000000001111100000" after 13 ns;
--    rw_s <= '0', '1' after 10 ns, '0' after 12 ns, '1' after 16 ns, '0' after 18 ns;

	----------------------- LH test -------------------------------------------
--    rst_s <= '1' after 5 ns;  -- reset active low
--    enable_s <= '1' after 7 ns, '0' after 11 ns, '1' after 13 ns; -- enable active high, at 7 ns the simulation begins

--	entrysize_s <= "01"; -- work with 32 bits all the time
--    entryunsigned_s <= 'Z'; -- does not matter

--    address_s <= "00000000000000000000000000000000", "00000000000000000000000000000100" after 13 ns; -- remeber to keep addresses aligned!!
--    datain_s <= "00011000000000000000000000001110", "01111000001111111111111111111111" after 13 ns;
--    rw_s <= '0', '1' after 10 ns, '0' after 12 ns, '1' after 16 ns, '0' after 18 ns;

	----------------------- LB test -------------------------------------------
--    rst_s <= '1' after 5 ns;  -- reset active low
--    enable_s <= '1' after 7 ns; -- '0' after 11 ns, '1' after 13 ns; -- enable active high, at 7 ns the simulation begins

--	entrysize_s <= "00"; -- work with 32 bits all the time
--    entryunsigned_s <= 'Z'; -- does not matter

--    address_s <= "00000000000000000000000000000000", "00000000000000000000000000000100" after 13 ns; -- remeber to keep addresses aligned!!
--    datain_s <= "00011000000000000000000000001110", "01111000001111111111111111111111" after 13 ns;
--    rw_s <= '0', '1' after 10 ns, '0' after 12 ns, '1' after 16 ns, '0' after 18 ns;

	----------------------- LBU bit test -------------------------------------------
--    rst_s <= '1' after 5 ns;  -- reset active low
--    enable_s <= '1' after 7 ns; -- '0' after 11 ns, '1' after 13 ns; -- enable active high, at 7 ns the simulation begins

--	entrysize_s <= "11", "00" after 10 ns, "11" after 12 ns, "00" after 16 ns, "11" after 18 ns; -- work with 32 bits all the time
--  entryunsigned_s <= '0'; -- does not matter

--    address_s <= "00000000000000000000000000000000", "00000000000000000000000000000100" after 13 ns; -- remeber to keep addresses aligned!!
--    datain_s <= "00011000000000000000000000001110", "01111000001111111111111111111111" after 13 ns;
--    rw_s <= '0', '1' after 10 ns, '0' after 12 ns, '1' after 16 ns, '0' after 18 ns;

	----------------------- LHU bit test -------------------------------------------
    -- rst_s <= '1' after 5 ns;  -- reset active low
    -- enable_s <= '1' after 7 ns; -- '0' after 11 ns, '1' after 13 ns; -- enable active high, at 7 ns the simulation begins
    --
    -- funct3_s <= "010", "001" after 23 ns, "000" after 25 ns, "001" after 27 ns, "010" after 29 ns; -- LW, LH, LB, SH, LW
  	-- --entrysize_s <= "11", "01" after 10 ns, "11" after 12 ns, "01" after 16 ns, "11" after 18 ns; -- work with 32 bits all the time
    -- --entryunsigned_s <= '1'; -- does not matter
    --
    -- datain_s <= "00011000000000000001000000001110", "01111000001111111111100111111001" after 13 ns;
    -- rw_s <= '1', '0' after 19 ns, '1' after 21 ns, '0' after 27 ns, '1' after 29 ns; -- '0' after 10 ns, '1' after 13 ns, '0' after 16 ns, '1' after 18 ns;

    rst_s <= '0', '1' after 3 ns;  -- reset active low
    enable_s <= '0', '1' after 5 ns; -- enable active high

    funct3_s <= "010", "001" after 7 ns, "000" after 9 ns, "010" after 11 ns, "001" after 13 ns, "000" after 15 ns, "101" after 17 ns, "100" after 19 ns; -- SW, SH, SB, LW, LH, LB, LHU, LBU

    address_s <= "00000000000000000000000000001100"; -- address aligned
    datain_s <= "00011000011110100001001000101110", "00000000000000001100110011111111" after 7 ns, "00000000000000001111111110101010" after 9 ns;
    rw_s <= '0', '1' after 11 ns;

end test;

configuration CFG_TB_DATAMEM of tb_datamem is
  for test
   for DUT : datamem
     use configuration work.CFG_DATAMEM_BEHAVIORAL;
   end for;
  end for;
end CFG_TB_DATAMEM;
