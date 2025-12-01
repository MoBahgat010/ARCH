library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
  generic (n: integer := 8);
  Port (
    a: in STD_LOGIC_VECTOR (n - 1 downto 0);
    b: in STD_LOGIC_VECTOR (n - 1 downto 0);
    cin: in std_logic;
    s: out STD_LOGIC_VECTOR (n - 1 downto 0);
    cout: out std_logic
  );
end full_adder;

architecture Structural of full_adder is
  component bit_adder
    Port (
      a: in STD_LOGIC;
      b: in STD_LOGIC;
      cin: in std_logic;
      s: out STD_LOGIC;
      cout: out std_logic
    );
  end component;
  SIGNAL temp : std_logic_vector(n DOWNTO 0);
  BEGIN
    temp(0) <= cin;
    loop1: FOR i IN 0 TO n-1 GENERATE
      fx: bit_adder PORT MAP(a(i),b(i),temp(i),s(i),temp(i+1));
    END GENERATE;
    cout <= temp(n);
  END Structural;