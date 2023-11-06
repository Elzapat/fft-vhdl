library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;

library work;
use work.twiddle_factor.all;

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
		data_out_r: out std_logic_vector(8*(l+3)-1 downto 0);
		data_out_i: out std_logic_vector(8*(l+3)-1 downto 0)
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

	-- Internal signals
	signal en1, en2, en3: std_logic;
	signal
		out_10_r, out_10_i, in_20_r, in_20_i,
		out_11_r, out_11_i, in_21_r, in_21_i,
		out_12_r, out_12_i, in_22_r, in_22_i,
		out_13_r, out_13_i, in_23_r, in_23_i,
		out_14_r, out_14_i, in_24_r, in_24_i,
		out_15_r, out_15_i, in_25_r, in_25_i,
		out_16_r, out_16_i, in_26_r, in_26_i,
		out_17_r, out_17_i, in_27_r, in_27_i
		: std_logic_vector(l downto 0);
	signal
		out_20_r, out_20_i, in_30_r, in_30_i,
		out_21_r, out_21_i, in_31_r, in_31_i,
		out_22_r, out_22_i, in_32_r, in_32_i,
		out_23_r, out_23_i, in_33_r, in_33_i,
		out_24_r, out_24_i, in_34_r, in_34_i,
		out_25_r, out_25_i, in_35_r, in_35_i,
		out_26_r, out_26_i, in_36_r, in_36_i,
		out_27_r, out_27_i, in_37_r, in_37_i
		: std_logic_vector(l+1 downto 0);
	signal
		out_30_r, out_30_i,
		out_31_r, out_31_i,
		out_32_r, out_32_i,
		out_33_r, out_33_i,
		out_34_r, out_34_i,
		out_35_r, out_35_i,
		out_36_r, out_36_i,
		out_37_r, out_37_i
		: std_logic_vector(l+2 downto 0);

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
			wr => w_0_8_real_14,
			wi => w_0_8_imag_14,
			S1r => out_10_r,
			S1i => out_10_i,
			S2r => out_14_r,
			S2i => out_14_i
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
			wr => w_1_8_real_14,
			wi => w_1_8_imag_14,
			S1r => out_11_r,
			S1i => out_11_i,
			S2r => out_15_r,
			S2i => out_15_i
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
			wr => w_2_8_real_14,
			wi => w_2_8_imag_14,
			S1r => out_12_r,
			S1i => out_12_i,
			S2r => out_16_r,
			S2i => out_16_i
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
			wr => w_3_8_real_14,
			wi => w_3_8_imag_14,
			S1r => out_13_r,
			S1i => out_13_i,
			S2r => out_17_r,
			S2i => out_17_i
		);

	-- Stage 2
	B21: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_20_r,
			Ai => in_20_i,
			Br => in_22_r,
			Bi => in_22_i,
			wr => w_0_8_real_15,
			wi => w_0_8_imag_15,
			S1r => out_20_r,
			S1i => out_20_i,
			S2r => out_22_r,
			S2i => out_22_i
		);

	B22: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_21_r,
			Ai => in_21_i,
			Br => in_23_r,
			Bi => in_23_i,
			wr => w_2_8_real_15,
			wi => w_2_8_imag_15,
			S1r => out_21_r,
			S1i => out_21_i,
			S2r => out_23_r,
			S2i => out_23_i
		);

	B23: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_24_r,
			Ai => in_24_i,
			Br => in_26_r,
			Bi => in_26_i,
			wr => w_0_8_real_15,
			wi => w_0_8_imag_15,
			S1r => out_24_r,
			S1i => out_24_i,
			S2r => out_26_r,
			S2i => out_26_i
		);

	B24: butterfly
		generic map(
			l => l+1,
			n => n
		)
		port map(
			Ar => in_25_r,
			Ai => in_25_i,
			Br => in_27_r,
			Bi => in_27_i,
			wr => w_2_8_real_15,
			wi => w_2_8_imag_15,
			S1r => out_25_r,
			S1i => out_25_i,
			S2r => out_27_r,
			S2i => out_27_i
		);

	-- Stage 3
	B31: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_30_r,
			Ai => in_30_i,
			Br => in_31_r,
			Bi => in_31_i,
			wr => w_0_8_real_16,
			wi => w_0_8_imag_16,
			S1r => out_30_r,
			S1i => out_30_i,
			S2r => out_31_r,
			S2i => out_31_i
		);

	B32: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_32_r,
			Ai => in_32_i,
			Br => in_33_r,
			Bi => in_33_i,
			wr => w_0_8_real_16,
			wi => w_0_8_imag_16,
			S1r => out_32_r,
			S1i => out_32_i,
			S2r => out_33_r,
			S2i => out_33_i
		);

	B33: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_34_r,
			Ai => in_34_i,
			Br => in_35_r,
			Bi => in_35_i,
			wr => w_0_8_real_16,
			wi => w_0_8_imag_16,
			S1r => out_34_r,
			S1i => out_34_i,
			S2r => out_35_r,
			S2i => out_35_i
		);

	B34: butterfly
		generic map(
			l => l+2,
			n => n
		)
		port map(
			Ar => in_36_r,
			Ai => in_36_i,
			Br => in_37_r,
			Bi => in_37_i,
			wr => w_0_8_real_16,
			wi => w_0_8_imag_16,
			S1r => out_36_r,
			S1i => out_36_i,
			S2r => out_37_r,
			S2i => out_37_i
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
				data_out_r(0*(l+3)+l+2 downto 0*(l+3)) <= out_30_r;
				data_out_i(0*(l+3)+l+2 downto 0*(l+3)) <= out_30_i;
				data_out_r(4*(l+3)+l+2 downto 4*(l+3)) <= out_31_r;
				data_out_i(4*(l+3)+l+2 downto 4*(l+3)) <= out_31_i;
				data_out_r(2*(l+3)+l+2 downto 2*(l+3)) <= out_32_r;
				data_out_i(2*(l+3)+l+2 downto 2*(l+3)) <= out_32_i;
				data_out_r(6*(l+3)+l+2 downto 6*(l+3)) <= out_33_r;
				data_out_i(6*(l+3)+l+2 downto 6*(l+3)) <= out_33_i;
				data_out_r(1*(l+3)+l+2 downto 1*(l+3)) <= out_34_r;
				data_out_i(1*(l+3)+l+2 downto 1*(l+3)) <= out_34_i;
				data_out_r(5*(l+3)+l+2 downto 5*(l+3)) <= out_35_r;
				data_out_i(5*(l+3)+l+2 downto 5*(l+3)) <= out_35_i;
				data_out_r(3*(l+3)+l+2 downto 3*(l+3)) <= out_36_r;
				data_out_i(3*(l+3)+l+2 downto 3*(l+3)) <= out_36_i;
				data_out_r(7*(l+3)+l+2 downto 7*(l+3)) <= out_37_r;
				data_out_i(7*(l+3)+l+2 downto 7*(l+3)) <= out_37_i;
			end if;
		end if;
	end process;
end architecture;
