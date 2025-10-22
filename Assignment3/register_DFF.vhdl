library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY my_nDFF IS
GENERIC ( n : integer := 8);
PORT(
    clk : IN std_logic;
    reset : IN std_logic;
    write_enable : IN std_logic;    
    d : IN std_logic_vector(n-1 DOWNTO 0);
    q : OUT std_logic_vector(n-1 DOWNTO 0)
);
END my_nDFF;

ARCHITECTURE one_dff OF my_nDFF IS
BEGIN
PROCESS(clk, reset) IS
BEGIN
    IF reset = '1' THEN
        q <= (others => '0');
    ELSIF rising_edge(clk) THEN
        IF write_enable = '1' THEN
            q <= d;
        END IF;
    END IF;
END PROCESS;
END one_dff;