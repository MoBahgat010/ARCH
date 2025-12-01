library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alsu is
  generic (n: integer := 8);
  Port (
    a: in STD_LOGIC_VECTOR (n - 1 downto 0);
    b: in STD_LOGIC_VECTOR (n - 1 downto 0);
    cin: in std_logic;
    sel: in STD_LOGIC_VECTOR (3 downto 0);
    f: out STD_LOGIC_VECTOR (n - 1 downto 0);
    cout: out std_logic
  );
end alsu;

architecture Behavioral of alsu is
  component porta
    generic (n: integer := 8);
    Port (
      a: in STD_LOGIC_VECTOR (n - 1 downto 0);
      b: in STD_LOGIC_VECTOR (n - 1 downto 0);
      sel: in STD_LOGIC_VECTOR (1 downto 0);
      cin: in std_logic;
      cout: out std_logic;
      f: out STD_LOGIC_VECTOR (n - 1 downto 0)
    );
  end component;

  component portb
    generic (n: integer := 8);
    Port (
      a: in STD_LOGIC_VECTOR (n - 1 downto 0);
      b: in STD_LOGIC_VECTOR (n - 1 downto 0);
      sel: in STD_LOGIC_VECTOR (1 downto 0);
      f: out STD_LOGIC_VECTOR (n - 1 downto 0);
      cout: out std_logic
    );
  end component;

  component portc
    generic (n: integer := 8);
    Port (
      a: in STD_LOGIC_VECTOR (n - 1 downto 0);
      cin: in std_logic;
      sel: in STD_LOGIC_VECTOR (1 downto 0);
      f: out STD_LOGIC_VECTOR (n - 1 downto 0);
      cout: out std_logic
    );
  end component;

  component portd
    generic (n: integer := 8);
    Port (
      a: in STD_LOGIC_VECTOR (n - 1 downto 0);
      cin: in std_logic;
      sel: in STD_LOGIC_VECTOR (1 downto 0);
      f: out STD_LOGIC_VECTOR (n - 1 downto 0);
      cout: out std_logic
    );
  end component;

  signal f1, f2, f3, f4: STD_LOGIC_VECTOR (n - 1 downto 0);
  signal c1, c2, c3, c4: std_logic;
begin
  pa: porta GENERIC MAP(n) PORT MAP(a, b, sel(1 downto 0), cin, c1, f1);
  pb: portb GENERIC MAP(n) PORT MAP(a, b, sel(1 downto 0), f2, c2);
  pc: portc GENERIC MAP(n) PORT MAP(a, cin, sel(1 downto 0), f3, c3);
  pd: portd GENERIC MAP(n) PORT MAP(a, cin, sel(1 downto 0), f4, c4);

  with sel(3 downto 2) select
  f <= f1 when "00",
        f2 when "01",
        f3 when "10",
        f4 when "11",
        (others => '0') when others;

  with sel(3 downto 2) select
  cout <= c1 when "00",
         c2 when "01",
         c3 when "10",
         c4 when "11",
         ('0') when others;
end Behavioral;