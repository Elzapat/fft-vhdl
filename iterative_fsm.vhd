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
		w_addr: out std_logic;
		w_en: out std_logic;
		r_addr: out std_logic;
		k: out std_logic
	);
end entity;

architecture states of iterative_fsm is

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
		elsif rising_edge(clk) then
			case state is
				when wait_data =>
				when receive =>
				when calcul =>
				when wait_out =>
				when transmit =>
				when others =>
			end case;
		end if;
	end process
end architecture;
