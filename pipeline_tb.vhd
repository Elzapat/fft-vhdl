library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity pipeline_tb is
end entity;

architecture example_pipeline of pipeline_tb is
    constant clk_period : time := 10 ns;

    constant data_in_filename : string := "data.in";
    constant data_out_filename : string := "data.out";

    component pipeline_top is
        generic(
            l: integer; -- Data size
            n: integer -- Bits after the decimal point
        );
        port(
            in_valid: in std_logic;
            out_ready: in std_logic;
            clk: in std_logic;
            arst_n: in std_logic;
            data_in_r: in std_logic_vector(8*l-1 downto 0);
            data_in_i: in std_logic_vector(8*l-1 downto 0);
            in_ready: out std_logic;
            out_valid: out std_logic;
            data_out_r: out std_logic_vector(8*(l+3)-1 downto 0);
            data_out_i: out std_logic_vector(8*(l+3)-1 downto 0)
        );
    end component;

    constant l: integer := 12;
    constant n: integer := 3;

    signal arst_n : std_logic := '1';
    signal clk : std_logic := '0';

    signal in_valid : std_logic := '0';
    signal out_ready : std_logic := '0';

    signal in_ready : std_logic := '0';
    signal out_valid : std_logic := '0';

    signal data_in_r : std_logic_vector(8*l-1 downto 0);
    signal data_in_i : std_logic_vector(8*l-1 downto 0);

    signal data_out_r : std_logic_vector(8*(l+3)-1 downto 0);
    signal data_out_i : std_logic_vector(8*(l+3)-1 downto 0);

    signal s_current_index : std_logic_vector(8 downto 0);
begin
    pipeline : pipeline_top
        generic map (
            l => l,
            n => n
        )
        port map (
            in_valid => in_valid,
            out_ready => out_ready,
            clk => clk,
            arst_n => arst_n,
            data_in_r => data_in_r,
            data_in_i => data_in_i,
            in_ready => in_ready,
            out_valid => out_valid,
            data_out_r => data_out_r,
            data_out_i => data_out_i
        );

    -- clock
    process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process;

    -- data in
    process
        file input_data : text;
        variable row : line;
        variable data_r, data_i : real;
        variable data_r_int, data_i_int : integer;
        variable current_index : integer := 0;
    begin
        -- in_valid <= '0';
        current_index := 0;
        file_open(input_data, data_in_filename, read_mode);

        if endfile(input_data) then
            report "Unexpected end of file" severity failure;
        end if;

        while not endfile(input_data) loop
            wait until rising_edge(clk);
            -- s_current_index <= std_logic_vector(current_index);

            if not endfile(input_data) then
                if in_ready = '1' and in_valid = '1' then
                    if endfile(input_data) then
                        report "Unexpected end of file" severity error;
                    else
                        readline(input_data, row);

                        read(row, data_r);
                        read(row, data_i);

                        data_r_int := integer(8.0 * data_r);
                        data_i_int := integer(8.0 * data_i);

                        data_in_r((current_index+1)*l-1 downto current_index*l) <= std_logic_vector(to_signed(data_r_int, l));
                        data_in_i((current_index+1)*l-1 downto current_index*l) <= std_logic_vector(to_signed(data_i_int, l));

                        current_index := (current_index + 1) mod 8;
                    end if;
                end if;
            end if;
        end loop;

        -- in_valid <= '1';

        file_close(input_data);

        wait for 50ns;

        report "end of input file" severity failure;
    end process;

    -- data out
    process
        file output_data : text open write_mode is data_out_filename;
        variable row : line;
        variable data_r : real;
        variable data_i : real;
        variable current_index : integer := 0;
    begin
        wait for 1 ns;

        if out_valid = '1' and out_ready = '1' then
			current_index := 0;
			while current_index < 8 loop
				data_r := real(to_integer(signed(data_out_r(current_index -- TODO -- )))) / 8.0;
				data_i := real(to_integer(signed(data_out_i(current_index -- TODO -- )))) / 8.0;

				write(row, data_r);
				write(row, ' ');
				write(row, data_i);
				writeline(output_data, row);
				current_index := current_index + 1;
			end loop;
        end if;

        wait until rising_edge(clk);
    end process;

    out_ready <= '1';

    process
    begin
        wait for 100 ns;

        --wait until rising_edge(clk);
        --wait for 3ns;

        in_valid <= '1';

        --wait until rising_edge(clk);
        --wait for 3ns;

        --in_valid <= '0';
    end process;
end architecture;
