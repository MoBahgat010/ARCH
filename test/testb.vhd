LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_test IS
END ENTITY;

ARCHITECTURE tsim OF tb_test IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL green_led,yellow_led, red_led: STD_LOGIC;

    CONSTANT CLK_PERIOD : TIME := 20 ns; -- 50 MHz clock

BEGIN
    DUT : ENTITY work.test
        PORT MAP(
            clk => clk,
            reset => reset,
            green_led => green_led,
            yellow_led => yellow_led,
            red_led => red_led
        );
    clk <= NOT clk AFTER CLK_PERIOD / 2;

    stim_proc : PROCESS
    BEGIN
        reset <= '1';
        WAIT FOR CLK_PERIOD;
        reset <= '0';
        WAIT FOR CLK_PERIOD;

        WAIT;
    END PROCESS;

END ARCHITECTURE tsim;
