library ieee;
use ieee.std_logic_1164.all;

entity fsm is
    port(
        arst_n: in std_logic;
        clk: in std_logic;
        in_valid: in std_logic;
        out_ready: in std_logic;
        in_ready: out std_logic;
        out_valid: out std_logic;
        en1: out std_logic;
        en2: out std_logic;
        en3: out std_logic
    );
end entity;

architecture states of fsm is
    signal state : std_logic_vector(2 downto 0) := "000";
begin
    process(clk, arst_n)
        if rising_edge(clk) then
            if arst_n = '1' then
                state <= "000";
            else
                case state is
                    when "000" =>
                        if in_valid = '0' then
                            state <= "000";
                        elsif in_valid = '1' then
                            state <= "100"
                        end if;

                    when "001" =>
                        if in_valid = '0' & out_ready = '0' then
                            state <= "001";
                        elsif in_valid = '0' & out_ready = '1' then
                            state <= "000";
                        elsif in_valid = '1' & out_ready = '0' then
                            state <= "101";
                        elsif in_valid = '1' & out_ready = '1' then
                            state <= "100";
                        end if;

                    when "010" =>
                        if in_valid = '0' then
                            state <= "001";
                        elsif in_valid = '1' then
                            state <= "101";
                        end if;

                    when "011" =>
                        if in_valid = '0' & out_ready = '0' then
                            state <= "011";
                        elsif in_valid = '0' & out_ready = '1' then
                            state <= "001";
                        elsif in_valid = '1' & out_ready = '0' then
                            state <= "111";
                        elsif in_valid = '1' & out_ready = '1' then
                            state <= "101";
                        end if;

                    when "100" =>
                        if in_valid = '0' then
                            state <= "010";
                        elsif in_valid = '1' then
                            state <= "110";
                        end if;

                    when "101" =>
                        if in_valid = '0' & out_ready = '0' then
                            state <= "011";
                        elsif in_valid = '0' & out_ready = '1' then
                            state <= "010";
                        elsif in_valid = '1' & out_ready = '0' then
                            state <= "111";
                        elsif in_valid = '1' & out_ready = '1' then
                            state <= "110";
                        end if;

                    when "110" =>
                        if in_valid = '0' then
                            state <= "011";
                        elsif in_valid = '1' then
                            state <= "111";
                        end if;

                    when "111" =>
                        if in_valid = '0' & out_ready = '0' then
                            state <= "111";
                        elsif in_valid = '0' & out_ready = '1' then
                            state <= "011";
                        elsif in_valid = '1' & out_ready = '0' then
                            state <= "111";
                        elsif in_valid = '1' & out_ready = '1' then
                            state <= "111";
                        end if;
                end case;
            end if
        end if;
    end process;
end architecture;
