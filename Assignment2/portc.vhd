library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity portc is
  generic (n: integer := 8);
  Port (
    a: in STD_LOGIC_VECTOR (n - 1 downto 0);
    cin: in std_logic;
    sel: in STD_LOGIC_VECTOR (1 downto 0);
    f: out STD_LOGIC_VECTOR (n - 1 downto 0);
    cout: out std_logic
  );
end portc;

architecture Behavioral of portc is
begin
  cout <= a(0);
  with sel select
    f <= ('0' & a(n - 1 downto 1)) when "00",
          (a(0) & a(n - 1 downto 1)) when "01",
          (cin & a(n - 1 downto 1)) when "10",
          (a(n - 1) & a(n - 1 downto 1)) when "11",
          (others => '0') when others;
end Behavioral;