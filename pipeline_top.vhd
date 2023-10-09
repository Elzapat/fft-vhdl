library ieee;
use ieee.std_logic_1164.all;

entity top is
	generic(
		l: integer; -- Data size
		n: integer; -- Bits after the decimal point
	);
	port(
		in_valid: in std_logic;
		out_ready: in std_logic;
		clk: in std_logic;
		arst: in std_logic;
		data_in_r: in array (7 downto 0) of std_logic_vector(n downto 0);
		data_in_i: in array (7 downto 0) of std_logic_vector(n downto 0);
		in_ready: out std_logic;
		out_valid: out std_logic;
		data_out_r: out array (7 downto 0) of std_logic_vector(n downto 0);
		data_out_i: out array (7 downto 0) of std_logic_vector(n downto 0);
	);
end entity;

architecture pipeline of top is
	component fsm is
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
	end component;

	component butterfly is
		generic(
			l: integer; -- Total number of bits
			n: integer  -- Bits after the decimal point
		);
		port(
			Ar: in std_logic_vector(l-1 downto 0); -- (1;l;n)
			Ai: in std_logic_vector(l-1 downto 0); -- (1;l;n)
			Br: in std_logic_vector(l-1 downto 0); -- (1;l;n)
			Bi: in std_logic_vector(l-1 downto 0); -- (1;l;n)
			wr: in std_logic_vector(l+1 downto 0); -- (1;l+2;l)
			wi: in std_logic_vector(l+1 downto 0); -- (1;l+2;l)
			S1r: out std_logic_vector(l downto 0); -- (1;l+1;n)
			S1i: out std_logic_vector(l downto 0);  -- (1;l+1;n)
			S2r: out std_logic_vector(l downto 0); -- (1;l+1;n)
			S2i: out std_logic_vector(l downto 0)  -- (1;l+1;n)
		);
	end component;

	signal en1, en2, en3: std_logic;
	signal out_1_r, out_1_i, in_2_r, in_2_i, out_2_r, out_2_i, in_3_r, in_3_i, out_3_r, out_3_i: std_logic_vector(7 downto 0);

begin
	control: fsm
		port map(
			arst_n => arst_n,
			clk => clk,
			in_valid => in_valid,
			out_ready => out_ready,
			in_ready => in_ready,
			out_valid => out_valid,
			en1 => en1,
			en2 => en2,
			en3 => en3
		);

	B11: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(0),
			Ai => data_in_i(0),
			Br => data_in_r(4),
			Bi => data_in_i(4),
			wr => --TODO
			wi => --TODO
			S1r => out_1_r(0),
			S1i => out_1_i(0),
			S2r => out_1_r(4),
			S2i => out_1_i(4)
		);

	B12: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(1),
			Ai => data_in_i(1),
			Br => data_in_r(5),
			Bi => data_in_i(5),
			wr => --TODO
			wi => --TODO
			S1r => out_1_r(1),
			S1i => out_1_i(1),
			S2r => out_1_r(5),
			S2i => out_1_i(5)
		);

	B13: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(2),
			Ai => data_in_i(2),
			Br => data_in_r(6),
			Bi => data_in_i(6),
			wr => --TODO
			wi => --TODO
			S1r => out_1_r(2),
			S1i => out_1_i(2),
			S2r => out_1_r(6),
			S2i => out_1_i(6)
		);

	B14: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(3),
			Ai => data_in_i(3),
			Br => data_in_r(7),
			Bi => data_in_i(7),
			wr => --TODO
			wi => --TODO
			S1r => out_1_r(3),
			S1i => out_1_i(3),
			S2r => out_1_r(7),
			S2i => out_1_i(7)
		);

	B21: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_2_r(0),
			Ai => in_2_i(0),
			Br => in_2_r(2),
			Bi => in_2_i(2),
			wr => --TODO
			wi => --TODO
			S1r => out_2_r(0),
			S1i => out_2_i(0),
			S2r => out_2_r(2),
			S2i => out_2_i(2)
		);

	B22: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_2_r(1),
			Ai => in_2_i(1),
			Br => in_2_r(3),
			Bi => in_2_i(3),
			wr => --TODO
			wi => --TODO
			S1r => out_2_r(1),
			S1i => out_2_i(1),
			S2r => out_2_r(3),
			S2i => out_2_i(3)
		);

	B23: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_2_r(4),
			Ai => in_2_i(4),
			Br => in_2_r(6),
			Bi => in_2_i(6),
			wr => --TODO
			wi => --TODO
			S1r => out_2_r(4),
			S1i => out_2_i(4),
			S2r => out_2_r(6),
			S2i => out_2_i(6)
		);

	B24: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_2_r(5),
			Ai => in_2_i(5),
			Br => in_2_r(7),
			Bi => in_2_i(7),
			wr => --TODO
			wi => --TODO
			S1r => out_2_r(5),
			S1i => out_2_i(5),
			S2r => out_2_r(7),
			S2i => out_2_i(7)
		);

	B31: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_3_r(0),
			Ai => in_3_i(0),
			Br => in_3_r(1),
			Bi => in_3_i(1),
			wr => --TODO
			wi => --TODO
			S1r => out_3_r(0),
			S1i => out_3_i(0),
			S2r => out_3_r(1),
			S2i => out_3_i(1)
		);

	B32: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_3_r(2),
			Ai => in_3_i(2),
			Br => in_3_r(3),
			Bi => in_3_i(3),
			wr => --TODO
			wi => --TODO
			S1r => out_3_r(2),
			S1i => out_3_i(2),
			S2r => out_3_r(3),
			S2i => out_3_i(3)
		);

	B33: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_3_r(4),
			Ai => in_3_i(4),
			Br => in_3_r(5),
			Bi => in_3_i(5),
			wr => --TODO
			wi => --TODO
			S1r => out_3_r(4),
			S1i => out_3_i(4),
			S2r => out_3_r(5),
			S2i => out_3_i(5)
		);

	B31: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => in_3_r(6),
			Ai => in_3_i(6),
			Br => in_3_r(7),
			Bi => in_3_i(7),
			wr => --TODO
			wi => --TODO
			S1r => out_3_r(6),
			S1i => out_3_i(6),
			S2r => out_3_r(7),
			S2i => out_3_i(7)
		);

end architecture;
