library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;

entity dram_init_mem is
    generic (
        EXTRA_PAYLOAD_FILE : string   := "";
        EXTRA_PAYLOAD_SIZE : integer  := 0
        );
    port (
        clk     : in std_ulogic
      );
end entity dram_init_mem;

architecture rtl of dram_init_mem is

    constant INIT_RAM_SIZE    : integer := 24576;
    constant RND_PAYLOAD_SIZE : integer := EXTRA_PAYLOAD_SIZE;
    constant TOTAL_RAM_SIZE   : integer := INIT_RAM_SIZE + RND_PAYLOAD_SIZE;
    constant INIT_RAM_ABITS   : integer := TOTAL_RAM_SIZE-1;
    constant INIT_RAM_FILE    : string := "litedram_core.init";

    type ram_t is array(0 to (TOTAL_RAM_SIZE / 4) - 1) of std_logic_vector(31 downto 0);

    -- XXX FIXME: Have a single init function called twice with
    -- an offset as argument
    --procedure init_load_payload(ram: inout ram_t; filename: string) is
    --    file payload_file : text open read_mode is filename;
    --    variable ram_line : line;
    --    variable temp_word : std_logic_vector(63 downto 0);
    --begin
    --    report "Opening payload file " & filename;
    --    for i in 0 to RND_PAYLOAD_SIZE-1 loop
    --        exit when endfile(payload_file);
    --        readline(payload_file, ram_line);
    --        hread(ram_line, temp_word);
    --        ram((INIT_RAM_SIZE/4) + i*2) := temp_word(31 downto 0);
    --        ram((INIT_RAM_SIZE/4) + i*2+1) := temp_word(63 downto 32);
    --    end loop;
    --    assert endfile(payload_file) report "Payload too big !" severity failure;
    --end procedure;

    impure function init_load_ram(name : string) return ram_t is
        file ram_file : text open read_mode is name;
        file payload_file : text;
        variable temp_word : std_logic_vector(63 downto 0);
        variable temp_ram : ram_t := (others => (others => '0'));
        variable ram_line : line;
    begin
        report "Payload size:" & integer'image(EXTRA_PAYLOAD_SIZE) &
            " rounded to:" & integer'image(RND_PAYLOAD_SIZE);
        report "Total RAM size:" & integer'image(TOTAL_RAM_SIZE) &
            " bytes using " & integer'image(INIT_RAM_ABITS) &
            " address bits";
        for i in 0 to (INIT_RAM_SIZE/8)-1 loop
            exit when endfile(ram_file);
            readline(ram_file, ram_line);
            hread(ram_line, temp_word);
            temp_ram(i*2) := temp_word(31 downto 0);
            temp_ram(i*2+1) := temp_word(63 downto 32);
        end loop;

        if RND_PAYLOAD_SIZE /= 0 then
            --init_load_payload(temp_ram, EXTRA_PAYLOAD_FILE);
            -- read from the payload file in a loop here to work around
            -- 'variable with access type is not synthesizable' from ghdl
            report "Opening payload file " & EXTRA_PAYLOAD_FILE;
            file_open(payload_file, EXTRA_PAYLOAD_FILE);
            for i in 0 to RND_PAYLOAD_SIZE-1 loop
                exit when endfile(payload_file);
                readline(payload_file, ram_line);
                hread(ram_line, temp_word);
                temp_ram((INIT_RAM_SIZE/4) + i*2) := temp_word(31 downto 0);
                temp_ram((INIT_RAM_SIZE/4) + i*2+1) := temp_word(63 downto 32);
            end loop;
            assert endfile(payload_file) report "Payload too big !" severity failure;

        end if;
        return temp_ram;
    end function;

    impure function init_zero return ram_t is
        variable temp_ram : ram_t := (others => (others => '0'));
    begin
        return temp_ram;
    end function;

    impure function initialize_ram(filename: string) return ram_t is
    begin
        report "Opening file " & filename;
        if filename'length = 0 then
            return init_zero;
        else
            return init_load_ram(filename);
        end if;
    end function;
    signal init_ram : ram_t := initialize_ram(INIT_RAM_FILE);

    attribute ram_style : string;
    attribute ram_style of init_ram: signal is "block";

    signal obuf : std_ulogic_vector(31 downto 0);
    signal oack : std_ulogic;
begin

    init_ram_0: process(clk)
        variable adr  : integer;
    begin
        if rising_edge(clk) then
            oack <= '0';
        end if;
    end process;

end architecture rtl;
