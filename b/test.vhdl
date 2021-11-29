library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity test is
	port (
	input : in std_logic
	);
end entity test;

architecture behaviour of test is
begin
    -- Init code BRAM memory slave 
    init_ram_0: entity dram_init_mem
        port map(
            clk => input
    	);

end behaviour;
