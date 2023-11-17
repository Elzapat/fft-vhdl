library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity butterfly is
  generic (
    l : integer := 14; n:integer);
  port (
    Ar : in std_logic_vector(l-1 downto 0);
    Ai : in std_logic_vector(l-1 downto 0);
    Br : in std_logic_vector(l-1 downto 0);
    Bi : in std_logic_vector(l-1 downto 0);
    wr : in std_logic_vector(l+1 downto 0);
    wi : in std_logic_vector(l+1 downto 0);
    S1r : out std_logic_vector(l downto 0);
    S1i : out std_logic_vector(l downto 0);
    S2r : out std_logic_vector(l downto 0);
    S2i : out std_logic_vector(l downto 0));

end entity butterfly;

architecture calcul of butterfly is

  signal Ar_signed, Ai_signed, Br_signed, Bi_signed : signed(l-1 downto 0);
  signal wr_signed, wi_signed : signed(l+1 downto 0);

  signal S1r_signed, S1i_signed, S2r_signed, S2i_signed : signed(l downto 0);

  signal Ar_moins_Br, Ai_moins_Bi : signed(l downto 0);

  signal wr_Ar_moins_Br, wr_Ai_moins_Bi, wi_Ar_moins_Br, wi_Ai_moins_Bi : signed(2*l+2 downto 0);

  signal S2r_full, S2i_full : signed(2*l+3 downto 0);

begin  -- architecture computation

  ---------------------------------------------
  -- Conversions signed <-> std_logic vector --
  ---------------------------------------------

  -- Entrées
  Ar_signed <= signed(Ar);
  Ai_signed <= signed(Ai);
  Br_signed <= signed(Br);
  Bi_signed <= signed(Bi);
  wr_signed <= signed(wr);
  wi_signed <= signed(wi);

  -- Sorties
  S1r <= std_logic_vector(S1r_signed);
  S1i <= std_logic_vector(S1i_signed);
  S2r <= std_logic_vector(S2r_signed);
  S2i <= std_logic_vector(S2i_signed);


  ----------------
  -- Calculs S1 --
  ----------------

  -- On passe les Ar, Ai, ... sur un bit de plus et on additionne
  S1r_signed <= (Ar_signed(l-1) & Ar_signed) + (Br_signed(l-1) & Br_signed);
  S1i_signed <= (Ai_signed(l-1) & Ai_signed) + (Bi_signed(l-1) & Bi_signed);

  
  ----------------
  -- Calculs S2 --
  ----------------

  -- Calculs de Ar-Br et Ai-Bi
  Ar_moins_Br <= (Ar_signed(l-1) & Ar_signed) - (Br_signed(l-1) & Br_signed);
  Ai_moins_Bi <= (Ai_signed(l-1) & Ai_signed) - (Bi_signed(l-1) & Bi_signed);

  -- Calculs des wx(Ax-bx)
  wr_Ar_moins_Br <= wr_signed*Ar_moins_Br;
  wr_Ai_moins_Bi <= wr_signed*Ai_moins_Bi;
  wi_Ar_moins_Br <= wi_signed*Ar_moins_Br;
  wi_Ai_moins_Bi <= wi_signed*Ai_moins_Bi;

  -- Calculs des S2r et S2i sur nombre complet de bits
  S2r_full <= (wr_Ar_moins_Br(2*l+1) & wr_Ar_moins_Br) - (wi_Ai_moins_Bi(2*l+1) & wi_Ai_moins_Bi);
  S2i_full <= (wr_Ai_moins_Bi(2*l+1) & wr_Ai_moins_Bi) + (wi_Ar_moins_Br(2*l+1) & wi_Ar_moins_Br);
  
  -- Recadrage et arrondi
  process(S2r_full)
  begin
    if S2r_full(l-1) = '1' then
      S2r_signed <= S2r_full(2*l downto l) + 1;
    else
      S2r_signed <= S2r_full(2*l downto l);
    end if;
  end process;

  process(S2i_full)
  begin
    if S2i_full(l-1) = '1' then
      S2i_signed <= S2i_full(2*l downto l) + 1;
    else
      S2i_signed <= S2i_full(2*l downto l);
    end if;
  end process;

end architecture calcul;

