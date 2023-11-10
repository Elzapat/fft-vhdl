library ieee;
use ieee.std_logic_1164.all;

entity iterative_fsm is
	port(
		arst_n: in std_logic;
		clk: in std_logic;
		in_valid: in std_logic;
		out_ready: in std_logic;
		out_valid: out std_logic;
		in_ready: out std_logic;
		sel_butterfly_output: out std_logic;
		sel_input: out std_logic;
		w_addr: out natural range 0 to 7;
		w_en: out std_logic;
		r_addr: out natural range 0 to 7;
		k: out natural range 0 to 3
	);
end entity;

architecture states of iterative_fsm is

	constant calcul_addr: array(0 to 23) of natural range 0 to 7 := (0, 4, 1, 5, 2, 6, 3, 7, 0, 2, 1, 3, 4, 6, 5, 7, 0, 1, 2, 3, 4, 5, 6, 7);
	constant k_values: array(0 to 11) of natural range 0 to 3 := (0, 1, 2, 3, 0, 2, 0, 2, 0, 0, 0, 0);

	component counter is
		port (
			arst_n: in std_logic;
			inc_cpt: in std_logic;
			rst_cpt: in std_logic;
			clk: in std_logic;
			cpt: out integer
		);
	end component;

	type state_t is (wait_data, receive, calcul, wait_out, transmit);

	signal state: state_t;
	signal inc_cpt, rst_cpt: std_logic;
	signal cpt: integer range 0 to 25;

begin

	cnt: counter
		port map(
			arst_n => arst_n,
			inc_cpt => inc_cpt,
			rst_cpt => rst_cpt,
			clk => clk,
			cpt => cpt
		);

	process(clk, arst_n)
	begin

		if arst_n = '0' then
			state <= wait_data;
			inc_cpt <= '0';
			rst_cpt <= '0';
			out_valid <= '0';
			in_ready <= '1';
			sel_butterfly_output <= '0';
			sel_input <= '0';
			w_addr <= 0;
			w_en <= '0';
			r_addr <= 0;
			k <= 0;

		elsif rising_edge(clk) then
			case state is

				when wait_data =>
					in_ready <= '1';
					inc_cpt <= in_valid;
					rst_cpt <= '0';
					w_en <= '1';
					sel_input <= '0';
					if in_valid = '1' then
						state <= receive;
					end if;

				when receive =>
					in_ready <= '0';
					inc_cpt <= '1';
					w_addr <= cpt;
					if cpt >= 7 then
						rst_cpt <= '1';
						state <= calcul;
					end if;

				when calcul =>
					sel_input <= '1';
					sel_butterfly_output <= std_logic_vector(to_unsigned(cpt(0), 15));
					if cpt > 1 then
						w_en <= '1';
						w_addr <= calcul_addr(cpt - 2);
					else
						w_en <= '0';
					end if;
					if cpt < 24 then
						r_addr <= calcul_addr(cpt);
						k <= k_values(cpt/2);
					end if;
					if cpt = 25 then
						rst_cpt <= '1';
						state <= wait_out;
					else
						rst_cpt <= '0';
					end if;

				when wait_out =>
					out_valid <= '1';
					inc_cpt <= out_ready;
					rst_cpt <= '0';
					w_en <= '0';
					w_addr <= 0;
					r_addr <= 0;
					if out_ready = '1' then
						state <= transmit;
					end if;

				when transmit =>
					out_valid <= '0';
					inc_cpt <= '1';
					r_addr <= cpt;
					if cpt >= 7 then
						rst_cpt <= '1';
						state <= wait_data;
					end if;

				when others =>
					state <= wait_data;

			end case;
		end if;

	end process
end architecture;
