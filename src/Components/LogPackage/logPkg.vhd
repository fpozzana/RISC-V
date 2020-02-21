library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

package log_pkg is
	function log2N (N: integer) return integer;
end;

package body log_pkg is

	function log2N (N: integer) return integer is
		variable temp: integer := N;
		variable res: integer := 0;
	begin
		while temp > 1 loop				
			res := res + 1;
			temp := temp / 2;
		end loop;
	return res;			
	end function;

end package body;
