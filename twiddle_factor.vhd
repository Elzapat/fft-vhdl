library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;

package twiddle_factor is
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

	-- 10 bits wide
    constant w_0_8_real_10 : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_0_8.RE * 16), 10));
    constant w_0_8_imag_10 : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_0_8.IM * 16), 10));

    constant w_1_8_real_10 : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * 16), 10));
    constant w_1_8_ima_10g : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * 16), 10));

    constant w_2_8_rea_10l : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_2_8.RE * 16), 10));
	constant w_2_8_imag_10 : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_2_8.IM * 16), 10));

    constant w_3_8_real_10 : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_3_8.RE * 16), 10));
    constant w_3_8_imag_10 : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(integer(w_3_8.IM * 16), 10));

	-- 11 bits wide
    constant w_0_8_real_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_0_8.RE * 18), 11));
    constant w_0_8_imag_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_0_8.IM * 18), 11));

    constant w_1_8_real_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * 18), 11));
    constant w_1_8_imag_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * 18), 11));

    constant w_2_8_real_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_2_8.RE * 18), 11));
    constant w_2_8_imag_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_2_8.IM * 18), 11));

    constant w_3_8_real_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_3_8.RE * 18), 11));
    constant w_3_8_imag_11 : std_logic_vector(10 downto 0) := std_logic_vector(to_signed(integer(w_3_8.IM * 18), 11));

	-- 12 bits wide
    constant w_0_8_real_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_0_8.RE * 20), 12));
    constant w_0_8_imag_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_0_8.IM * 20), 12));

    constant w_1_8_real_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * 20), 12));
    constant w_1_8_imag_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * 20), 12));

    constant w_2_8_real_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_2_8.RE * 20), 12));
    constant w_2_8_imag_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_2_8.IM * 20), 12));

    constant w_3_8_real_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_3_8.RE * 20), 12));
    constant w_3_8_imag_12 : std_logic_vector(11 downto 0) := std_logic_vector(to_signed(integer(w_3_8.IM * 20), 12));
end package;
