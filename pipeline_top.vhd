library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;

entity top is
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
		data_out_r: out std_logic_vector(8*(l+2)-1 downto 0);
		data_out_i: out std_logic_vector(8*(l+2)-1 downto 0)
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

	-- w coefficient values computation
    constant twiddle_factor_width : integer := 10; -- Taille totale de w
    constant factor_resize_multiplier : real := 2.0**(twiddle_factor_width-2);

    constant Pi : real := 3.14159265;

    constant exp_factor_0_8 : complex := (0.0, -(2.0*Pi*real(0)/real(8)));
    constant exp_factor_1_8 : complex := (0.0, -(2.0*Pi*real(1)/real(8)));
    constant exp_factor_2_8 : complex := (0.0, -(2.0*Pi*real(2)/real(8)));
    constant exp_factor_3_8 : complex := (0.0, -(2.0*Pi*real(3)/real(8)));

    constant w_0_8 : complex := EXP(exp_factor_0_8);
    constant w_1_8 : complex := EXP(exp_factor_1_8);
    constant w_2_8 : complex := EXP(exp_factor_2_8);
    constant w_3_8 : complex := EXP(exp_factor_3_8);

    constant w_0_8_real : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_0_8.RE * factor_resize_multiplier), twiddle_factor_width));
    constant w_0_8_imag : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_0_8.IM * factor_resize_multiplier), twiddle_factor_width));

    constant w_1_8_real : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * factor_resize_multiplier), twiddle_factor_width));
    constant w_1_8_imag : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * factor_resize_multiplier), twiddle_factor_width));

    constant w_2_8_real : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_2_8.RE * factor_resize_multiplier), twiddle_factor_width));
    constant w_2_8_imag : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_2_8.IM * factor_resize_multiplier), twiddle_factor_width));

    constant w_3_8_real : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_3_8.RE * factor_resize_multiplier), twiddle_factor_width));
    constant w_3_8_imag : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_3_8.IM * factor_resize_multiplier), twiddle_factor_width));

	signal en1, en2, en3: std_logic;
	signal out_1_r, out_1_i, in_2_r, in_2_i: std_logic_vector(8*l-1 downto 0);
	signal out_2_r, out_2_i, in_3_r, in_3_i: std_logic_vector(8*(l+1)-1 downto 0);
	signal out_3_r, out_3_i: std_logic_vector(8*(l+2)-1 downto 0);

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

	-- Stage 1
	B11: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(0*l+l-1 downto 0*l),
			Ai => data_in_i(0*l+l-1 downto 0*l),
			Br => data_in_r(4*l+l-1 downto 4*l),
			Bi => data_in_i(4*l+l-1 downto 4*l),
			wr => w_0_8_real,
			wi => w_0_8_imag,
			S1r => out_1_r(0*(l+1)+l downto 0*(l+1)),
			S1i => out_1_i(0*(l+1)+l downto 0*(l+1)),
			S2r => out_1_r(4*(l+1)+l downto 4*(l+1)),
			S2i => out_1_i(4*(l+1)+l downto 4*(l+1))
		);

	B12: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(1*l+l-1 downto 1*l),
			Ai => data_in_i(1*l+l-1 downto 1*l),
			Br => data_in_r(5*l+l-1 downto 5*l),
			Bi => data_in_i(5*l+l-1 downto 5*l),
			wr => w_1_8_real,
			wi => w_1_8_imag,
			S1r => out_1_r(1*(l+1)+l downto 1*(l+1)),
			S1i => out_1_i(1*(l+1)+l downto 1*(l+1)),
			S2r => out_1_r(5*(l+1)+l downto 5*(l+1)),
			S2i => out_1_i(5*(l+1)+l downto 5*(l+1))
		);

	B13: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(2*l+l-1 downto 2*l),
			Ai => data_in_i(2*l+l-1 downto 2*l),
			Br => data_in_r(6*l+l-1 downto 6*l),
			Bi => data_in_i(6*l+l-1 downto 6*l),
			wr => w_2_8_real,
			wi => w_2_8_imag,
			S1r => out_1_r(2*(l+1)+l downto 2*(l+1)),
			S1i => out_1_i(2*(l+1)+l downto 2*(l+1)),
			S2r => out_1_r(6*(l+1)+l downto 6*(l+1)),
			S2i => out_1_i(6*(l+1)+l downto 6*(l+1))
		);

	B14: butterfly
		generic map(
			l => l,
			n => n
		)
		port map(
			Ar => data_in_r(3*l+l-1 downto 3*l),
			Ai => data_in_i(3*l+l-1 downto 3*l),
			Br => data_in_r(7*l+l-1 downto 7*l),
			Bi => data_in_i(7*l+l-1 downto 7*l),
			wr => w_3_8_real,
			wi => w_3_8_imag,
			S1r => out_1_r(3*(l+1)+l downto 3*(l+1)),
			S1i => out_1_i(3*(l+1)+l downto 3*(l+1)),
			S2r => out_1_r(7*(l+1)+l downto 7*(l+1)),
			S2i => out_1_i(7*(l+1)+l downto 7*(l+1))
		);

	-- Stage 2
	B21: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_2_r(0*(l+1)+l downto 0*(l+1)),
			Ai => in_2_i(0*(l+1)+l downto 0*(l+1)),
			Br => in_2_r(2*(l+1)+l downto 2*(l+1)),
			Bi => in_2_i(2*(l+1)+l downto 2*(l+1)),
			wr => w_0_8_real,
			wi => w_0_8_imag,
			S1r => out_2_r(0*(l+2)+l+1 downto 0*(l+2)),
			S1i => out_2_i(0*(l+2)+l+1 downto 0*(l+2)),
			S2r => out_2_r(2*(l+2)+l+1 downto 2*(l+2)),
			S2i => out_2_i(2*(l+2)+l+1 downto 2*(l+2))
		);

	B22: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_2_r(1*(l+1)+l downto 1*(l+1)),
			Ai => in_2_i(1*(l+1)+l downto 1*(l+1)),
			Br => in_2_r(3*(l+1)+l downto 3*(l+1)),
			Bi => in_2_i(3*(l+1)+l downto 3*(l+1)),
			wr => w_2_8_real,
			wi => w_2_8_imag,
			S1r => out_2_r(1*(l+2)+l+1 downto 1*(l+2)),
			S1i => out_2_i(1*(l+2)+l+1 downto 1*(l+2)),
			S2r => out_2_r(3*(l+2)+l+1 downto 3*(l+2)),
			S2i => out_2_i(3*(l+2)+l+1 downto 3*(l+2))
		);

	B23: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_2_r(4*(l+1)+l downto 4*(l+1)),
			Ai => in_2_i(4*(l+1)+l downto 4*(l+1)),
			Br => in_2_r(6*(l+1)+l downto 6*(l+1)),
			Bi => in_2_i(6*(l+1)+l downto 6*(l+1)),
			wr => w_0_8_real,
			wi => w_0_8_imag,
			S1r => out_2_r(4*(l+2)+l+1 downto 4*(l+2)),
			S1i => out_2_i(4*(l+2)+l+1 downto 4*(l+2)),
			S2r => out_2_r(6*(l+2)+l+1 downto 6*(l+2)),
			S2i => out_2_i(6*(l+2)+l+1 downto 6*(l+2))
		);

	B24: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_2_r(5*(l+1)+l downto 5*(l+1)),
			Ai => in_2_i(5*(l+1)+l downto 5*(l+1)),
			Br => in_2_r(7*(l+1)+l downto 7*(l+1)),
			Bi => in_2_i(7*(l+1)+l downto 7*(l+1)),
			wr => w_2_8_real,
			wi => w_2_8_imag,
			S1r => out_2_r(5*(l+2)+l+1 downto 5*(l+2)),
			S1i => out_2_i(5*(l+2)+l+1 downto 5*(l+2)),
			S2r => out_2_r(7*(l+2)+l+1 downto 7*(l+2)),
			S2i => out_2_i(7*(l+2)+l+1 downto 7*(l+2))
		);

	-- Stage 3
	B31: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_3_r(0*(l+2)+l+1 downto 0*(l+2)),
			Ai => in_3_i(0*(l+2)+l+1 downto 0*(l+2)),
			Br => in_3_r(1*(l+2)+l+1 downto 1*(l+2)),
			Bi => in_3_i(1*(l+2)+l+1 downto 1*(l+2)),
			wr => w_0_8_real,
			wi => w_0_8_imag,
			S1r => out_3_r(0*(l+3)+l+2 downto 0*(l+3)),
			S1i => out_3_i(0*(l+3)+l+2 downto 0*(l+3)),
			S2r => out_3_r(1*(l+3)+l+2 downto 1*(l+3)),
			S2i => out_3_i(1*(l+3)+l+2 downto 1*(l+3))
		);

	B32: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_3_r(2*(l+2)+l+1 downto 2*(l+2)),
			Ai => in_3_i(2*(l+2)+l+1 downto 2*(l+2)),
			Br => in_3_r(3*(l+2)+l+1 downto 3*(l+2)),
			Bi => in_3_i(3*(l+2)+l+1 downto 3*(l+2)),
			wr => w_0_8_real,
			wi => w_0_8_imag,
			S1r => out_3_r(2*(l+3)+l+2 downto 2*(l+3)),
			S1i => out_3_i(2*(l+3)+l+2 downto 2*(l+3)),
			S2r => out_3_r(3*(l+3)+l+2 downto 3*(l+3)),
			S2i => out_3_i(3*(l+3)+l+2 downto 3*(l+3))
		);

	B33: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_3_r(4*(l+2)+l+1 downto 4*(l+2)),
			Ai => in_3_i(4*(l+2)+l+1 downto 4*(l+2)),
			Br => in_3_r(5*(l+2)+l+1 downto 5*(l+2)),
			Bi => in_3_i(5*(l+2)+l+1 downto 5*(l+2)),
			wr => w_0_8_real,
			wi => w_0_8_imag,
			S1r => out_3_r(4*(l+3)+l+2 downto 4*(l+3)),
			S1i => out_3_i(4*(l+3)+l+2 downto 4*(l+3)),
			S2r => out_3_r(5*(l+3)+l+2 downto 5*(l+3)),
			S2i => out_3_i(5*(l+3)+l+2 downto 5*(l+3))
		);

	B34: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_3_r(6*(l+2)+l+1 downto 6*(l+2)),
			Ai => in_3_i(6*(l+2)+l+1 downto 6*(l+2)),
			Br => in_3_r(7*(l+2)+l+1 downto 7*(l+2)),
			Bi => in_3_i(7*(l+2)+l+1 downto 7*(l+2)),
			wr => w_0_8_real,
			wi => w_0_8_imag,
			S1r => out_3_r(6*(l+3)+l+2 downto 6*(l+3)),
			S1i => out_3_i(6*(l+3)+l+2 downto 6*(l+3)),
			S2r => out_3_r(7*(l+3)+l+2 downto 7*(l+3)),
			S2i => out_3_i(7*(l+3)+l+2 downto 7*(l+3))
		);

	-- Inter-stage registers
	process(arst_n, clk)
	begin
		if arst_n = '0' then
			out_1_r <= (others => '0');
			out_1_i <= (others => '0');
			in_2_r <= (others => '0');
			in_2_i <= (others => '0');
			out_2_r <= (others => '0');
			out_2_i <= (others => '0');
			in_3_r <= (others => '0');
			in_3_i <= (others => '0');
			out_3_r <= (others => '0');
			out_3_i <= (others => '0');
			data_out_r <= (others => '0');
			data_out_i <= (others => '0');
		elsif rising_edge(clk) then
			if en1 = '1' then
				in_2_r <= out_1_r;
				in_2_i <= out_1_i;
			end if;
			if en2 = '1' then
				in_3_r <= out_2_r;
				in_3_i <= out_2_i;
			end if;
			if en3 = '1' then
				data_out_r(0*(l+3)+l+2 downto 0*(l+3)) <= out_3_r(0*(l+3)+l+2 downto 0*(l+3));
				data_out_i(0*(l+3)+l+2 downto 0*(l+3)) <= out_3_i(0*(l+3)+l+2 downto 0*(l+3));
				data_out_r(4*(l+3)+l+2 downto 4*(l+3)) <= out_3_r(1*(l+3)+l+2 downto 1*(l+3));
				data_out_i(4*(l+3)+l+2 downto 4*(l+3)) <= out_3_i(1*(l+3)+l+2 downto 1*(l+3));
				data_out_r(2*(l+3)+l+2 downto 2*(l+3)) <= out_3_r(2*(l+3)+l+2 downto 2*(l+3));
				data_out_i(2*(l+3)+l+2 downto 2*(l+3)) <= out_3_i(2*(l+3)+l+2 downto 2*(l+3));
				data_out_r(6*(l+3)+l+2 downto 6*(l+3)) <= out_3_r(3*(l+3)+l+2 downto 3*(l+3));
				data_out_i(6*(l+3)+l+2 downto 6*(l+3)) <= out_3_i(3*(l+3)+l+2 downto 3*(l+3));
				data_out_r(1*(l+3)+l+2 downto 1*(l+3)) <= out_3_r(4*(l+3)+l+2 downto 4*(l+3));
				data_out_i(1*(l+3)+l+2 downto 1*(l+3)) <= out_3_i(4*(l+3)+l+2 downto 4*(l+3));
				data_out_r(5*(l+3)+l+2 downto 5*(l+3)) <= out_3_r(5*(l+3)+l+2 downto 5*(l+3));
				data_out_i(5*(l+3)+l+2 downto 5*(l+3)) <= out_3_i(5*(l+3)+l+2 downto 5*(l+3));
				data_out_r(3*(l+3)+l+2 downto 3*(l+3)) <= out_3_r(6*(l+3)+l+2 downto 6*(l+3));
				data_out_i(3*(l+3)+l+2 downto 3*(l+3)) <= out_3_i(6*(l+3)+l+2 downto 6*(l+3));
				data_out_r(7*(l+3)+l+2 downto 7*(l+3)) <= out_3_r(7*(l+3)+l+2 downto 7*(l+3));
				data_out_i(7*(l+3)+l+2 downto 7*(l+3)) <= out_3_i(7*(l+3)+l+2 downto 7*(l+3));
			end if;
		end if;
	end process;
end architecture;
