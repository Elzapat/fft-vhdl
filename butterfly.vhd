library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity butterfly is
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
		S1i: out std_logic_vector(l downto 0)  -- (1;l+1;n)
		S2r: out std_logic_vector(l downto 0); -- (1;l+1;n)
		S2i: out std_logic_vector(l downto 0)  -- (1;l+1;n)
	);
end entity;

architecture compute of butterfly is
	signal wrAr, wrAi, wrBr, wrBi, wiAr, wiAi, wiBr, wiBi: std_logic_vector(2*l+1 downto 0); -- (1;2*l+2;l)
begin
	-- S1 = A + B
	S1r <= std_logic_vector(to_signed(to_integer(signed(Ar)) + to_integer(signed(Br)), l+1));
	S1i <= std_logic_vector(to_signed(to_integer(signed(Ai)) + to_integer(signed(Bi)), l+1));

	-- S2 = w(A + B)
	wrAr <= std_logic_vector(to_signed(to_integer(signed(wr)) * to_integer(signed(Ar)), 2*l+2));
	wrAi <= std_logic_vector(to_signed(to_integer(signed(wr)) * to_integer(signed(Ai)), 2*l+2));
	wrBr <= std_logic_vector(to_signed(to_integer(signed(wr)) * to_integer(signed(Br)), 2*l+2));
	wrBi <= std_logic_vector(to_signed(to_integer(signed(wr)) * to_integer(signed(Bi)), 2*l+2));
	wiAr <= std_logic_vector(to_signed(to_integer(signed(wi)) * to_integer(signed(Ar)), 2*l+2));
	wiAi <= std_logic_vector(to_signed(to_integer(signed(wi)) * to_integer(signed(Ai)), 2*l+2));
	wiBr <= std_logic_vector(to_signed(to_integer(signed(wi)) * to_integer(signed(Br)), 2*l+2));
	wiBi <= std_logic_vector(to_signed(to_integer(signed(wi)) * to_integer(signed(Bi)), 2*l+2));

	S2r <= std_logic_vector(to_signed(
		   to_integer(signed(wrAr(2*l-n+1 downto l-n))) + to_integer(signed('0' & wrAr(l-n-1))) -- Approximation
		   - to_integer(signed(wrBr(2*l-n+1 downto l-n))) + to_integer(signed('0' & wrBr(l-n-1))) -- Approximation
		   - to_integer(signed(wiAi(2*l-n+1 downto l-n))) + to_integer(signed('0' & wiAi(l-n-1))) -- Approximation
		   + to_integer(signed(wiBi(2*l-n+1 downto l-n))) + to_integer(signed('0' & wiBi(l-n-1))) -- Approximation
		   , l+1));

	S2i <= std_logic_vector(to_signed(
		   to_integer(signed(wrAi(2*l-n+1 downto l-n))) + to_integer(signed('0' & wrAi(l-n-1))) -- Approximation
		   - to_integer(signed(wrBi(2*l-n+1 downto l-n))) + to_integer(signed('0' & wrBi(l-n-1))) -- Approximation
		   + to_integer(signed(wiAr(2*l-n+1 downto l-n))) + to_integer(signed('0' & wiAr(l-n-1))) -- Approximation
		   - to_integer(signed(wiBr(2*l-n+1 downto l-n))) + to_integer(signed('0' & wiBr(l-n-1))) -- Approximation
		   , l+1));
end architecture;
