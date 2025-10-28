LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity ssd IS
    PORT (
        hex_in  : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
        ssd_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END ENTITY ssd;

ARCHITECTURE behavior OF ssd IS
BEGIN
    PROCESS(hex_in)
    BEGIN
        CASE hex_in IS
            WHEN "0000" => ssd_out <= "0000001"; -- 0
            WHEN "0001" => ssd_out <= "1001111"; -- 1
            WHEN "0010" => ssd_out <= "0010010"; -- 2
            WHEN "0011" => ssd_out <= "0000110"; -- 3
            WHEN "0100" => ssd_out <= "1001100"; -- 4
            WHEN "0101" => ssd_out <= "0100100"; -- 5
            WHEN "0110" => ssd_out <= "0100000"; -- 6
            WHEN "0111" => ssd_out <= "0001111"; -- 7
            WHEN "1000" => ssd_out <= "0000000"; -- 8
            WHEN "1001" => ssd_out <= "0000100"; -- 9
            WHEN "1010" => ssd_out <= "0001000"; -- A
            WHEN "1011" => ssd_out <= "1100000"; -- B
            WHEN "1100" => ssd_out <= "0110001"; -- C
            WHEN "1101" => ssd_out <= "1000010"; -- D
            WHEN "1110" => ssd_out <= "0110000"; -- E
            WHEN "1111" => ssd_out <= "0111000"; -- F
            WHEN OTHERS => ssd_out <= "1111111"; -- Blank
        END CASE;
    END PROCESS;
END ARCHITECTURE behavior;