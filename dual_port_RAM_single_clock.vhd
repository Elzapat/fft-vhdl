library ieee;
use ieee.std_logic_1164.all;

entity dual_port_ram_single_clock is
  generic (
    DATA_WIDTH : natural := 8;
    ADDR_WIDTH : natural := 6
    );
  port (
    clk : in std_logic;
    addr_a : in natural range 0 to 2**ADDR_WIDTH - 1;
    addr_b : in natural range 0 to 2**ADDR_WIDTH - 1;
    data_a : in std_logic_vector((DATA_WIDTH-1) downto 0);
    data_b : in std_logic_vector((DATA_WIDTH-1) downto 0);
    we_a : in std_logic;
    we_b : in std_logic;
    q_a : out std_logic_vector((DATA_WIDTH -1) downto 0);
    q_b : out std_logic_vector((DATA_WIDTH -1) downto 0)
    );
end dual_port_ram_single_clock;

architecture rtl of dual_port_ram_single_clock is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
  type memory_t is array((2**ADDR_WIDTH - 1) downto 0) of word_t;

  -- Declare the RAM signal.
  shared variable ram : memory_t;

begin
  process(clk)
  begin
    if(rising_edge(clk)) then           -- Port A
      if(we_a = '1') then
        ram(addr_a) := data_a;
        -- Read-during-write on the same port returns NEW data
        q_a         <= data_a;
      else
        -- Read-during-write on the mixed port returns OLD data
        q_a <= ram(addr_a);
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(rising_edge(clk)) then           -- Port B
      if(we_b = '1') then
        ram(addr_b) := data_b;
        -- Read-during-write on the same port returns NEW data
        q_b <= data_b;
      else
        -- Read-during-write on the mixed port returns OLD data
        q_b <= ram(addr_b);
      end if;
    end if;
  end process;
end rtl;
