library ieee;
use work.log_pkg.all;                               --package that contains the definition of log2(x)
use ieee.std_logic_1164.all;

package globals is
--constants used for the testbenches of every component--
	-------------mux---------------------------
	constant NumBitMux21 : integer := 32;
	-------------register----------------------
	constant NumBitRegister : integer := 32;
	-------------register enable---------------
	constant NumBitRegisterEnable : integer := 32;
	-------------register file-----------------
	constant NumBitData : integer := 32;
	constant NumBitRegisterFile : integer := 32;
	constant NumBitAddress : integer := log2N(NumBitRegisterFile);
	-------------IRAM--------------------------
	constant RAM_DEPTH : integer := 30;
	constant I_SIZE : integer := 32;
	------- DATA MEMORY -----------------------
	constant datamem_length : integer := 16384; -- 2^16
	constant vector_length : integer := 28; -- 7 elements, 4 mem positions per element
	constant vector_start_address : std_logic_vector(31 downto 0) := "00000000000000000010000000000000";
	constant vector_end_address   : std_logic_vector(31 downto 0) := "00000000000000000010000000011100";  -- start + 28

	type datamem_storage is array (0 to datamem_length-1) of std_logic_vector (7 downto 0);
	type datamem_vector is array (0 to vector_length-1) of std_logic_vector (7 downto 0);
end globals;
