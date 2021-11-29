
entity litedram_wrapper is

end entity litedram_wrapper;

architecture behaviour of litedram_wrapper is


begin
    -- Init code BRAM memory slave 
    init_ram_0: entity dram_init_mem
        generic map(
            EXTRA_PAYLOAD_FILE => PAYLOAD_FILE,
            EXTRA_PAYLOAD_SIZE => PAYLOAD_SIZE
            )
        port map(
            clk => system_clk
    	);

end architecture behaviour;
