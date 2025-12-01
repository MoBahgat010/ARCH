library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity portd is
  generic (n: integer := 8);
  Port (
    a: in STD_LOGIC_VECTOR (n - 1 downto 0);
    cin: in std_logic;
    sel: in STD_LOGIC_VECTOR (1 downto 0);
    f: out STD_LOGIC_VECTOR (n - 1 downto 0);
    cout: out std_logic
  );
end portd;

architecture Behavioral of portd is
begin
  cout <= '0' when sel = "11" else a(n - 1);
  with sel select
  f <= (a(n - 2 downto 0) & '0') when "00",
        (a(n - 2 downto 0) & a(n - 1)) when "01",
        (a(n - 2 downto 0) & cin) when "10",
        (others => '0') when "11",
        (others => '0') when others;

end Behavioral;