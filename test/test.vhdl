LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.MATH_REAL.ALL;

ENTITY TrafficLight IS
    GENERIC(
        CLK_FREQ: INTEGER := 50_000_000
    );
    PORT(
        RESET, CLK, CLK_Enable: IN STD_LOGIC;
        green: OUT STD_LOGIC;
        yellow: OUT STD_LOGIC;
        red: OUT STD_LOGIC
    );
END ENTITY TrafficLight;

Architecture traffic OF TrafficLight is
    SIGNAL clk_counter: INTEGER RANGE 0 TO CLK_FREQ - 1 := 0;
    SIGNAL clk_1sec_enable: STD_LOGIC := '0';
    SIGNAL counter: INTEGER RANGE 0 TO 24 := 0;
    SIGNAL next_counter: INTEGER RANGE 0 TO 24;
    BEGIN
    PROCESS(CLK, RESET)
    BEGIN
        IF(rising_edge(CLK)) THEN
            clk_1sec_enable <= '0';
            IF(RESET = '0') THEN
                clk_counter <= 0;
            ELSIF(clk_counter = CLK_FREQ - 1) THEN
                clk_counter <= 0;
                clk_1sec_enable <= '1';
            ELSE
                clk_counter <= clk_counter + 1;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(CLK, RESET)
    BEGIN
        IF(RESET = '0') THEN
            counter <= 0;
            green <= '1';
            yellow <= '0';
            red <= '0';
        ELSIF(rising_edge(CLK)) THEN
            IF(CLK_Enable = '1') THEN
                counter <= next_counter;
            END IF;
            
            IF(counter < 10) THEN
                green <= '1';
                yellow <= '0';
                red <= '0';
            ELSIF(counter < 15) THEN
                green <= '0';
                yellow <= '1';
                red <= '0';
            ELSE
                green <= '0';
                yellow <= '0';
                red <= '1';
            END IF;
        END IF;
    END PROCESS;
    
    next_counter <= 0 WHEN counter = 24 ELSE counter + 1;
END Architecture traffic;