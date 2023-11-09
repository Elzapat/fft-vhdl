library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port (
        arst_n: in std_logic;
        inc_cpt: in std_logic;
        rst_cpt: in std_logic;
        clk: in std_logic;
        cpt: out integer range 0 to 25
    );
end entity;

architecture count of counter is
    signal counter: integer := 0;
begin
    process(clk, arst_n)
    begin
        if arst_n = '0' then
            counter <= 0;
        elsif rising_edge(clk) then
            if rst_cpt = '1' then
                counter <= 0;
            elsif inc_cpt = '1' then
                counter <= counter + 1;
            end if;

            cpt <= counter;
        end if;
    end process;
end architecture;
