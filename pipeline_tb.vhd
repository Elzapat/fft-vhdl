library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_tb is
end entity;

architecture example_pipeline of pipeline_tb is
    component top is
        generic(
            l: integer; -- Data size
            n: integer -- Bits after the decimal point
        );
        port(
            in_valid: in std_logic;
            out_ready: in std_logic;
            clk: in std_logic;
            arst: in std_logic;
            data_in_r: in array(0 to 7) of std_logic_vector(l-1 downto 0);
            data_in_i: in array(0 to 7) of std_logic_vector(l-1 downto 0);
            in_ready: out std_logic;
            out_valid: out std_logic;
            data_out_r: out array(0 to 7) of std_logic_vector(l+1 downto 0);
            data_out_i: out array(0 to 7) of std_logic_vector(l+1 downto 0)
        );
    end component;

    constant l: integer := 6;
    constant n: integer := 1;

    signal arst_n : std_logic := '0';
    signal clk : std_logic := '0';
    signal arst_n : std_logic := '0';

    signal in_valid : std_logic := '0';
    signal out_ready : std_logic := '0';

    signal in_ready : std_logic := '0';
    signal out_valid : std_logic := '0';
begin
    process
    begin
    end process;
end architecture;
