library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.twiddle_factor.all;

entity iterative_top is
	generic(
		l: integer; -- Data size
		n: integer -- Bits after the decimal point
	);
	port(
		in_valid: in std_logic;
		out_ready: in std_logic;
		clk: in std_logic;
		arst_n: in std_logic;
		data_in_r: in std_logic_vector(l downto 0);
		data_in_i: in std_logic_vector(l downto 0);
		in_ready: out std_logic;
		out_valid: out std_logic;
		data_out_r: out std_logic_vector(l downto 0);
		data_out_i: out std_logic_vector(l downto 0)
	);
end entity;

architecture top of iterative_top is
    component dual_port_ram_single_clock is
        generic (
            DATA_WIDTH: natural := 8;
            ADDR_WIDTH: natural := 6
        );
        port (
            clk: in std_logic;
            addr_a: in natural range 0 to 2**ADDR_WIDTH - 1;
            addr_b: in natural range 0 to 2**ADDR_WIDTH - 1;
            data_a: in std_logic_vector((DATA_WIDTH-1) downto 0);
            data_b: in std_logic_vector((DATA_WIDTH-1) downto 0);
            we_a: in std_logic;
            we_b: in std_logic;
            q_a: out std_logic_vector((DATA_WIDTH -1) downto 0);
            q_b: out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

    component iterative_fsm is
        port(
            arst_n: in std_logic;
            clk: in std_logic;
            in_valid: in std_logic;
            out_ready: in std_logic;
            out_valid: out std_logic;
            in_ready: out std_logic;
            sel_butterfly_output: out std_logic;
            sel_input: out std_logic;
            w_addr: out std_logic;
            w_en: out std_logic;
            r_addr: out std_logic;
            k: out std_logic
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

    -- Butterfly signals
    signal Ar, Ai, Br, Bi: std_logic_vector(l-1 downto 0);
    signal wr, wi: std_logic_vector(l+1 downto 0);
    signal S1r, S1i, S2r, S2i: std_logic_vector(l downto 0);

    -- FSM signals
    signal sel_butterfly_input, sel_input, w_en: std_logic := '0';
    signal w_addr, r_addr: natural range 0 to 7;
    signal k: natural range 0 to 3;

    -- Butterfly input delay
    signal butterfly_input_r: std_logic_vector(l downto 0);
    signal butterfly_input_i: std_logic_vector(l downto 0);

    signal butterfly_output_r: std_logic_vector(l downto 0);
    signal butterfly_output_i: std_logic_vector(l downto 0);

    signal data_in_ext_r: std_logic_vector(l downto 0);
    signal data_in_ext_i: std_logic_vector(l downto 0);

    signal data_in_ram_r: std_logic_vector(l downto 0);
    signal data_in_ram_i: std_logic_vector(l downto 0);

    signal data_out_ram_r: std_logic_vector(l downto 0);
    signal data_out_ram_i: std_logic_vector(l downto 0);
begin
    butterfly_inst : butterfly
        generic map (
            l => l,
            n => n
        )
        port map (
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

    fsm_inst : iterative_fsm
        port map (
            arst_n => arst_n,
            clk => clk,
            in_valid => in_valid,
            out_ready => out_ready,
            out_valid => out_valid,
            in_ready => in_ready,
            sel_butterfly_output => sel_butterfly_output,
            sel_input => sel_input,
            w_addr => w_addr,
            w_en => w_en,
            r_addr => w_addr,
            k => k
        );

    real_ram_inst : dual_port_ram_single_clock
        generic map (
            DATA_WIDTH => 12;
            ADDR_WIDTH => 3
        )
        port map (
            clk => clk,
            addr_a => w_addr,
            addr_b => r_addr,
            data_a => data_in_ram_i,
            data_b => "000000000000",
            we_a => w_en,
            we_b => '0',
            q_a => q_a_r,
            q_b => data_out_ram_r
        );

    imag_ram_inst : dual_port_ram_single_clock
        generic map (
            DATA_WIDTH => 12;
            ADDR_WIDTH => 3
        )
        port map (
            clk => clk,
            addr_a => addr_a_i,
            addr_b => addr_b_i,
            data_a => data_in_ram_r,
            data_b => "000000000000",
            we_a => w_en,
            we_b => '0',
            q_a => q_a_i,
            q_b => data_out_ram_i
        );

    data_in_ext_r(11 downto 0) <= data_in_r;
    data_in_ext_r(l downto 12) <= (others => data_in_r(11));
    data_in_ext_i(11 downto 0) <= data_in_i;
    data_in_ext_i(l downto 12) <= (others => data_in_i(11));

    Br <= data_b_r;
    Bi <= data_b_i;

    butterfly_input_r <= data_out_ram_r;
    butterfly_input_i <= data_out_ram_i;

    wi <= w_k_8_r(k);
    wr <= w_k_8_i(k);

    data_out_r <= data_out_ram_r;
    data_out_i <= data_out_ram_i;

    process(clk, arst_n) is
        if arst_n = '0' then
            butterfly_input_r <= (others => '0');
            butterfly_input_i <= (others => '0');
        elsif rising_edge(clk) then
            Ar <= butterfly_input_r;
            Ai <= butterfly_input_i;

            butterfly_output_r <= S2r;
            butterfly_output_i <= S2i;

            if sel_input = '0' then
                data_in_ram_r <= data_in_ext_r;
                data_in_ram_o <= data_in_ext_i;
            elsif sel_butterfly_input = '0' then
                data_in_ram_r <= S1r;
                data_in_ram_i <= S1i;
            else
                data_in_ram_r <= butterfly_output_r;
                data_in_ram_i <= butterfly_output_i;
            end if;
        end if;
    end process
end architucture;
