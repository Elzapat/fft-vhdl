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
		S1i: out std_logic_vector(l downto 0);  -- (1;l+1;n)
		S2r: out std_logic_vector(l downto 0); -- (1;l+1;n)
		S2i: out std_logic_vector(l downto 0)  -- (1;l+1;n)
	);
end entity;

architecture compute of butterfly is
	signal wrAr, wrAi, wrBr, wrBi, wiAr, wiAi, wiBr, wiBi: integer range 0 to 2**(2*l+2)-1; --std_logic_vector(2*l+1 downto 0); -- (1;2*l+2;l)
	signal S2r_full, S2i_full: std_logic_vector(2*l+3 downto 0); -- (1;2*l+4;l)
begin
	-- S1 = A + B
	S1r <= std_logic_vector(to_signed(to_integer(signed(Ar)) + to_integer(signed(Br)), l+1));
	S1i <= std_logic_vector(to_signed(to_integer(signed(Ai)) + to_integer(signed(Bi)), l+1));

	-- S2 = w(A + B)
	wrAr <= to_integer(signed(wr)) * to_integer(signed(Ar));
	wrAi <= to_integer(signed(wr)) * to_integer(signed(Ai));
	wrBr <= to_integer(signed(wr)) * to_integer(signed(Br));
	wrBi <= to_integer(signed(wr)) * to_integer(signed(Bi));
	wiAr <= to_integer(signed(wi)) * to_integer(signed(Ar));
	wiAi <= to_integer(signed(wi)) * to_integer(signed(Ai));
	wiBr <= to_integer(signed(wi)) * to_integer(signed(Br));
	wiBi <= to_integer(signed(wi)) * to_integer(signed(Bi));

	S2r_full <= std_logic_vector(to_signed(wrAr - wrBr - wiAi + wiBi, 2*l+4));
	S2i_full <= std_logic_vector(to_signed(wrAi - wtBi + wiAr - wiBr, 2*l+4));

	-- Approximation on l+1 bits with precision n
	S2r <= std_logic_vector(signed(S2r_full(2*l-n+1 downto l-n)) + signed("0" & S2r_full(l-n-1)));
	S2i <= std_logic_vector(signed(S2i_full(2*l-n+1 downto l-n)) + signed("0" & S2i_full(l-n-1)));
end architecture;
