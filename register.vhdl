library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Assignment_Array IS
PORT (
    clk: IN STD_LOGIC;
    reset: IN STD_LOGIC;
    write_enable: IN STD_LOGIC;
    rd_addr0: IN STD_LOGIC_VECTOR(2 downto 0);
    rd_addr1: IN STD_LOGIC_VECTOR(2 downto 0);
    wr_addr: IN STD_LOGIC_VECTOR(2 downto 0);
    data_in: IN STD_LOGIC_VECTOR(7 downto 0);
    data_out0: OUT STD_LOGIC_VECTOR(7 downto 0);
    data_out1: OUT STD_LOGIC_VECTOR(7 downto 0)
);
END ENTITY Assignment_Array;
    
ARCHITECTURE register_file_arch OF Assignment_Array is
TYPE reg_file_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(7 downto 0);
SIGNAL reg: reg_file_type;
BEGIN
PROCESS(clk, reset) IS
BEGIN
    IF reset = '1' THEN
        loop0: FOR i IN 0 TO 7 LOOP
            reg(i) <= (others => '0');
        END LOOP;

    ELSIF rising_edge(clk) THEN
        IF write_enable = '1' THEN
            reg(to_integer(unsigned(wr_addr))) <= data_in;
        END IF;
    END IF;
    END PROCESS;
    data_out0 <= reg(to_integer(unsigned(rd_addr0)));
    data_out1 <= reg(to_integer(unsigned(rd_addr1)));
END register_file_arch;