library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;

package twiddle_factor is
    -- constant factor_resize_multiplier : real := 2.0**(twiddle_factor_width-2);

    constant Pi : real := 3.14159265;

    constant exp_factor_0_8 : complex := (0.0, -(2.0*Pi*real(0)/real(8)));
    constant exp_factor_1_8 : complex := (0.0, -(2.0*Pi*real(1)/real(8)));
    constant exp_factor_2_8 : complex := (0.0, -(2.0*Pi*real(2)/real(8)));
    constant exp_factor_3_8 : complex := (0.0, -(2.0*Pi*real(3)/real(8)));

    constant w_0_8 : complex := EXP(exp_factor_0_8);
    constant w_1_8 : complex := EXP(exp_factor_1_8);
    constant w_2_8 : complex := EXP(exp_factor_2_8);
    constant w_3_8 : complex := EXP(exp_factor_3_8);

	-- 10 bits wide
    constant w_0_8_real_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_0_8.RE * 24.0), 14));
    constant w_0_8_imag_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_0_8.IM * 24.0), 14));

    constant w_1_8_real_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * 24.0), 14));
    constant w_1_8_imag_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * 24.0), 14));

    constant w_2_8_real_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_2_8.RE * 24.0), 14));
	constant w_2_8_imag_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_2_8.IM * 24.0), 14));

    constant w_3_8_real_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_3_8.RE * 24.0), 14));
    constant w_3_8_imag_14 : std_logic_vector(13 downto 0) := std_logic_vector(to_signed(integer(w_3_8.IM * 24.0), 14));

	-- 11 bits wide
    constant w_0_8_real_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_0_8.RE * 26.0), 15));
    constant w_0_8_imag_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_0_8.IM * 26.0), 15));

    constant w_1_8_real_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * 26.0), 15));
    constant w_1_8_imag_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * 26.0), 15));

    constant w_2_8_real_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_2_8.RE * 26.0), 15));
    constant w_2_8_imag_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_2_8.IM * 26.0), 15));

    constant w_3_8_real_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_3_8.RE * 26.0), 15));
    constant w_3_8_imag_15 : std_logic_vector(14 downto 0) := std_logic_vector(to_signed(integer(w_3_8.IM * 26.0), 15));

	-- 12 bits wide
    constant w_0_8_real_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_0_8.RE * 28.0), 16));
    constant w_0_8_imag_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_0_8.IM * 28.0), 16));

    constant w_1_8_real_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * 28.0), 16));
    constant w_1_8_imag_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * 28.0), 16));

    constant w_2_8_real_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_2_8.RE * 28.0), 16));
    constant w_2_8_imag_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_2_8.IM * 28.0), 16));

    constant w_3_8_real_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_3_8.RE * 28.0), 16));
    constant w_3_8_imag_16 : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(integer(w_3_8.IM * 28.0), 16));

	type twiddle_vec is array(0 to 3) of std_logic_vector(15 downto 0);

	constant w_k_8_r : twiddle_vec := (w_0_8_real_16, w_1_8_real_16, w_2_8_real_16, w_3_8_real_16);
	constant w_k_8_i : twiddle_vec := (w_0_8_imag_16, w_1_8_imag_16, w_2_8_imag_16, w_3_8_imag_16);
end package;
