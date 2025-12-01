LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.MATH_REAL.ALL;

ENTITY washing_machine IS 
    PORT(
        clk, clk_en, reset: IN STD_LOGIC;
        fill, wash, rinse: OUT STD_LOGIC;
        spin: OUT STD_LOGIC
    );
END ENTITY washing_machine;

ARCHITECTURE behavior OF washing_machine IS
    SIGNAL counter: INTEGER RANGE 0 TO 280 := 0;
    SIGNAL wash_signal, rinse_signal, spin_signal, fill_signal: STD_LOGIC := '0';
BEGIN
    wash <= wash_signal;
    rinse <= rinse_signal;
    spin <= spin_signal;
    fill <= fill_signal;

    PROCESS(clk, reset)
    BEGIN
        IF(reset = '0') THEN
            counter <= 0;
            fill_signal <= '0';
            wash_signal <= '0';
            rinse_signal <= '0';
            spin_signal <= '0';
        ELSIF(rising_edge(clk)) THEN
            IF(clk_en = '1') THEN
                counter <= (counter + 1) MOD 280;
                IF(counter < 60) THEN
                    fill_signal <= '1';
                    wash_signal <= '0';
                    rinse_signal <= '0';
                    spin_signal <= '0';
                ELSIF(counter < 160) THEN
                    fill_signal <= '0';
                    wash_signal <= '1';
                    rinse_signal <= '0';
                    spin_signal <= '0';
                ELSIF(counter < 200) THEN
                    fill_signal <= '0';
                    wash_signal <= '0';
                    rinse_signal <= '1';
                    spin_signal <= '0';
                ELSIF(counter < 280) THEN
                    fill_signal <= '0';
                    wash_signal <= '0';
                    rinse_signal <= '0';
                    spin_signal <= '1';
                END IF;
            END IF;   
        END IF;
    END PROCESS;
END ARCHITECTURE behavior;