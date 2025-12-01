library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bit_adder is
  Port (
    a: in STD_LOGIC;
    b: in STD_LOGIC;
    cin: in std_logic;
    s: out STD_LOGIC;
    cout: out std_logic
  );
end bit_adder;

architecture Behavioral of bit_adder is
begin
  s <= a XOR b XOR cin;
  cout <= (a AND b) OR (cin AND (a XOR b));
end Behavioral;
