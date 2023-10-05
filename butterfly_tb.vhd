library ieee;
use ieee.std_logic_1164.all;
use ieee.natural_std.all;

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
    constant l: integer := 16;
    constant n: integer := 8;

    signal Ar, Ai, Br, Bi: std_logic_vector(l-1 downto 0);
    signal wr, wi: std_logic_vector(l+1 downto 0);
    signal S1r, S1i, S2r, S2i: std_logic_vector(l downto 0);

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
            wr => wr,
            wi => wi,
            S1r => S1r,
            S1i => S1i,
            S2r => S2r,
            S2i => S2i
        );

    process
    begin
    end process;
end architecture;
