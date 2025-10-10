library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY register_file IS
GENERIC(n: integer := 8);
PORT (
    clk: IN STD_LOGIC;
    reset: IN STD_LOGIC;
    write_enable: IN STD_LOGIC;
    read_enable: IN STD_LOGIC; -- 0 read port0, 1 read port1
    rd_addr0: IN STD_LOGIC_VECTOR(2 downto 0);
    rd_addr1: IN STD_LOGIC_VECTOR(2 downto 0);
    wr_addr: IN STD_LOGIC_VECTOR(2 downto 0);
    data_in: IN STD_LOGIC_VECTOR(n-1 downto 0);
    data_out0: OUT STD_LOGIC_VECTOR(n-1 downto 0);
    data_out1: OUT STD_LOGIC_VECTOR(n-1 downto 0)
);
END ENTITY register_file;
    
ARCHITECTURE register_file_arch OF register_file is
TYPE reg_file_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL reg: reg_file_type;
BEGIN
PROCESS(clk) IS
BEGIN
    IF rising_edge(clk) THEN
        IF reset = '1' THEN
            loop1: FOR i IN 0 TO 7 LOOP
                reg(i) <= (others => '0');
            END LOOP;
        data_out0 <= (others => '0');
        data_out1 <= (others => '0');
        ELSE
            IF write_enable = '1' THEN
                reg(to_integer(unsigned(wr_addr))) <= data_in;
            END IF;
            IF read_enable = '1' THEN
                data_out0 <= reg(to_integer(unsigned(rd_addr0)));
                data_out1 <= reg(to_integer(unsigned(rd_addr1)));
            END IF;
        END IF;
    END IF;
END PROCESS;
END register_file_arch;