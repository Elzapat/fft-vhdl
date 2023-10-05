library ieee;
use ieee.std_logic_1164.all;
use ieee.natural_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;

entity butterfly_tb is
end entity

architecture example of butterfly_tb is
    component butterfly is
        generic(
            l: integer;
            n: integer
        );
        port(
            Ar: in std_logic_vector(l-1 downto 0);
            Ai: in std_logic_vector(l-1 downto 0);
            Br: in std_logic_vector(l-1 downto 0);
            Bi: in std_logic_vector(l-1 downto 0);
            wr: in std_logic_vector(l+1 downto 0);
            wi: in std_logic_vector(l+1 downto 0);
            S1r: out std_logic_vector(l downto 0);
            S1i: out std_logic_vector(l downto 0);
            S2r: out std_logic_vector(l downto 0);
            S2i: out std_logic_vector(l downto 0);
        );
    end component butterfly;
begin
    constant twiddle_factor_width : integer := 8; -- Taille totale de w
    constant factor_resize_multiplier : real := 2.0**(twiddle_factor_width-2);

    constant Pi : real := 3.14159265;

    constant exp_factor_1_8 : complex := (0.0, -(2.0*Pi*real(1)/real(8)));

    constant w_1_8 : complex := EXP(exp_factor_1_8);

    constant w_1_8_real : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_1_8.RE * factor_resize_multiplier), twiddle_factor_width));
    constant w_1_8_imag : std_logic_vector(twiddle_factor_width-1 downto 0) := std_logic_vector(to_signed(integer(w_1_8.IM * factor_resize_multiplier), twiddle_factor_width));


    constant l: integer := 16;
    constant n: integer := 8;

    signal Ar, Ai, Br, Bi: std_logic_vector(l-1 downto 0) := ; -- A valeur bidon et B 0, on observe A et w * A en sortie
    -- Deuxieme test, A = B, 2A sur la premiere sortie et 0 sur la deuxieme
    signal S1r, S1i, S2r, S2i: std_logic_vector(l downto 0); -- Troisieme test, deux cst aleatoire et on fait le calcul et on vérifie

    butterfly_op : butterfly
        generic map(
            l => l,
            n => n
        );
        port map(
            Ar => Ar,
            Ai => Ai,
            Br => Br,
            Bi => Bi,
            wr => w_1_8_real,
            wi => w_1_8_imag,
            S1r => S1r,
            S1i => S1i,
            S2r => S2r,
            S2i => S2i
        );

    process
    begin
        Ar <= std_logic_vector(to_signed(3));
        Ai <= std_logic_vector(to_signed(2));
        Br <= std_logic_vector(to_signed(0));
        Bi <= std_logic_vector(to_signed(0));

        wait for 100 ns;

        Ar <= std_logic_vector(to_signed(8));
        Ai <= std_logic_vector(to_signed(3));
        Br <= std_logic_vector(to_signed(8));
        Bi <= std_logic_vector(to_signed(3));

        wait for 100 ns;

        Ar <= std_logic_vector(to_signed(93));
        Ai <= std_logic_vector(to_signed(21));
        Br <= std_logic_vector(to_signed(49));
        Bi <= std_logic_vector(to_signed(29));

        wait for 100 ns;
    end process;
end architecture;
