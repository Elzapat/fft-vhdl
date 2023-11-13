library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

	type calcul_addr_t is array(0 to 23) of natural range 0 to 7;
	type k_values_t is array(0 to 11) of natural range 0 to 3;

	constant calcul_addr: calcul_addr_t := (0, 4, 1, 5, 2, 6, 3, 7, 0, 2, 1, 3, 4, 6, 5, 7, 0, 1, 2, 3, 4, 5, 6, 7);
	constant k_values: k_values_t := (0, 1, 2, 3, 0, 2, 0, 2, 0, 0, 0, 0);

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

	signal state, next_state: state_t;
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
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process;

	process(state, in_valid, cpt)
		variable cpt_logic: std_logic_vector(14 downto 0);
	begin
		case state is

			when wait_data =>
				in_ready <= '1';
				out_valid <= '0';
				inc_cpt <= in_valid;
				rst_cpt <= '0';
				w_en <= '1';
				sel_input <= '0';
				sel_butterfly_output <= '0';
				w_addr <= '0';
				r_addr <= '0';
				if in_valid = '1' then
					next_state <= receive;
				else
					next_state <= wait_data;
				end if;

			when receive =>
				in_ready <= '0';
				out_valid <= '0';
				inc_cpt <= '1';
				w_en <= '1';
				sel_input <= '0';
				sel_butterfly_output <= '0';
				w_addr <= cpt;
				r_addr <= '0';
				if cpt >= 7 then
					rst_cpt <= '1';
					next_state <= calcul;
				else
					rst_cpt <= '0';
					next_state <= receive;
				end if;

			when calcul =>
				in_ready <= '0';
				out_valid <= '0';
				inc_cpt <= '1';
				sel_input <= '1';
				cpt_logic := std_logic_vector(to_unsigned(cpt, 15));
				sel_butterfly_output <= cpt_logic(0);
				if cpt > 1 then
					w_en <= '1';
					w_addr <= calcul_addr(cpt - 2);
				else
					w_en <= '0';
					w_addr <= 0;
				end if;
				if cpt < 24 then
					r_addr <= calcul_addr(cpt);
					k <= k_values(cpt/2);
				else
					r_addr <= 0;
					k <= 0;
				end if;
				if cpt = 25 then
					rst_cpt <= '1';
					next_state <= wait_out;
				else
					rst_cpt <= '0';
					next_state <= calcul;
				end if;

			when wait_out =>
				in_ready <= '0';
				out_valid <= '1';
				inc_cpt <= out_ready;
				rst_cpt <= '0'
				sel_input <= '0';
				sel_butterfly_output <= '0';
				w_en <= '0';
				w_addr <= 0;
				r_addr <= 0;
				if out_ready = '1' then
					next_state <= transmit;
				else
					next_state <= wait_out;
				end if;

			when transmit =>
				in_ready <= '0';
				out_valid <= '0';
				inc_cpt <= '1';
				sel_input <= '0';
				sel_butterfly_output <= '0';
				w_en <= '0';
				w_addr <= 0;
				r_addr <= cpt;
				if cpt >= 7 then
					rst_cpt <= '1';
					next_state <= wait_data;
				else
					rst_cpt <= '0';
					next_state <= transmit;
				end if;

			when others =>
				next_state <= wait_data;

		end case;
	end process;
end architecture;
