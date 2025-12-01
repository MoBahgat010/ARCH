library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity porta is
  generic (n: integer := 8);
  Port (
    a: in STD_LOGIC_VECTOR (n - 1 downto 0);
    b: in STD_LOGIC_VECTOR (n - 1 downto 0);
    sel: in STD_LOGIC_VECTOR (1 downto 0);
    cin: in std_logic;
    cout: out std_logic;
    f: out STD_LOGIC_VECTOR (n - 1 downto 0)
  );
end porta;

architecture Behavioral of porta is
  component full_adder
    Port (
      a: in STD_LOGIC_VECTOR (n - 1 downto 0);
      b: in STD_LOGIC_VECTOR (n - 1 downto 0);
      cin: in std_logic;
      s: out STD_LOGIC_VECTOR (n - 1 downto 0);
      cout: out std_logic
    );
  end component;
  signal new_b: STD_LOGIC_VECTOR (n - 1 downto 0);
  signal temp_cout: STD_LOGIC;
begin

  new_b <= (others => '0') when sel = "00" else
           b when sel = "01" else
           (not b) when sel = "10" else
           (others => '1') when sel = "11" and cin = '0' else
           (not a) when sel = "11" and cin = '1' else
           (others => '0');

  fa: full_adder GENERIC MAP (n) PORT MAP(a, new_b, cin, f, temp_cout);
  cout <= '0' when sel = "11" and cin = '1' else temp_cout;

end Behavioral;




