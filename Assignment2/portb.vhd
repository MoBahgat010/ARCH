library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity portb is
  generic (n: integer := 8);
  Port (
    a: in STD_LOGIC_VECTOR (n - 1 downto 0);
    b: in STD_LOGIC_VECTOR (n - 1 downto 0);
    sel: in STD_LOGIC_VECTOR (1 downto 0);
    f: out STD_LOGIC_VECTOR (n - 1 downto 0);
    cout: out std_logic
  );
end portb;

architecture Behavioral of portb is
begin
  cout <= '0';
  with sel select
    f <= (a and b) when "00",
         (a or b) when "01",
         (a nor b) when "10",
         (not a) when "11",
         (others => '0') when others;
end Behavioral;