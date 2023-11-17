library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;

library work;
use work.twiddle_factor.all;

entity butterfly_tb is
end entity;

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
            S2i: out std_logic_vector(l downto 0)
        );
    end component butterfly;

    constant l: integer := 12;
    constant n: integer := 3;

    signal Ar, Ai, Br, Bi: std_logic_vector(l-1 downto 0);
    signal S1r, S1i, S2r, S2i: std_logic_vector(l downto 0); 

begin

    butterfly_op : butterfly
        generic map(
            l => l,
            n => n
        )
        port map(
            Ar => Ar,
            Ai => Ai,
            Br => Br,
            Bi => Bi,
            wr => w_1_8_real_14,
            wi => w_1_8_imag_14,
            S1r => S1r,
            S1i => S1i,
            S2r => S2r,
            S2i => S2i
        );

    process
    begin 
        -- Premier test, A valeur bidon et B 0, on observe A et w * A en sortie
        Ar <= std_logic_vector(to_signed(200, Ar'length));
        Ai <= std_logic_vector(to_signed(200, Ai'length));
        Br <= std_logic_vector(to_signed(200, Br'length));
        Bi <= std_logic_vector(to_signed(200, Bi'length));

        wait for 100 ns;

        -- Deuxieme test, A = B, 2A sur la premiere sortie et 0 sur la deuxieme
        Ar <= std_logic_vector(to_signed(8, Ar'length));
        Ai <= std_logic_vector(to_signed(3, Ai'length));
        Br <= std_logic_vector(to_signed(8, Br'length));
        Bi <= std_logic_vector(to_signed(3, Bi'length));

        wait for 100 ns;

        -- Troisieme test, deux cst aleatoire et on fait le calcul et on vérifie
        Ar <= std_logic_vector(to_signed(93, Ar'length));
        Ai <= std_logic_vector(to_signed(31, Ai'length));
        Br <= std_logic_vector(to_signed(49, Br'length));
        Bi <= std_logic_vector(to_signed(29, Bi'length));

        wait for 100 ns;
    end process;
end architecture;
