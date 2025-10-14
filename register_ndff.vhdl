library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Assignment3 IS
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
END ENTITY Assignment3;

ARCHITECTURE register_file_nDFF OF Assignment3 is
  COMPONENT my_nDFF
    GENERIC ( n : integer := 8);
    PORT(
        clk : IN std_logic;
        reset : IN std_logic;
        write_enable : IN std_logic;
        d : IN std_logic_vector(n-1 DOWNTO 0);
        q : OUT std_logic_vector(n-1 DOWNTO 0)
    );
  END COMPONENT;
  SIGNAL reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7: STD_LOGIC_VECTOR(7 downto 0);
  SIGNAL we: STD_LOGIC_VECTOR(7 downto 0);
BEGIN
  U0: my_nDFF PORT MAP (clk, reset, we(0), data_in, reg0);
  U1: my_nDFF PORT MAP (clk, reset, we(1), data_in, reg1);
  U2: my_nDFF PORT MAP (clk, reset, we(2), data_in, reg2);
  U3: my_nDFF PORT MAP (clk, reset, we(3), data_in, reg3);
  U4: my_nDFF PORT MAP (clk, reset, we(4), data_in, reg4);
  U5: my_nDFF PORT MAP (clk, reset, we(5), data_in, reg5);
  U6: my_nDFF PORT MAP (clk, reset, we(6), data_in, reg6);
  U7: my_nDFF PORT MAP (clk, reset, we(7), data_in, reg7);

 we <= (others => '0') when write_enable = '0' else
       "00000001" when wr_addr = "000" else
       "00000010" when wr_addr = "001" else
       "00000100" when wr_addr = "010" else
       "00001000" when wr_addr = "011" else
       "00010000" when wr_addr = "100" else
       "00100000" when wr_addr = "101" else
       "01000000" when wr_addr = "110" else
       "10000000" when wr_addr = "111" else
       (others => '0');

  WITH rd_addr0 SELECT
    data_out0 <= reg0 WHEN "000",
                 reg1 WHEN "001",
                 reg2 WHEN "010",
                 reg3 WHEN "011",
                 reg4 WHEN "100",
                 reg5 WHEN "101",
                 reg6 WHEN "110",
                 reg7 WHEN "111",
                 (others => '0') WHEN OTHERS;
  WITH rd_addr1 SELECT
    data_out1 <= reg0 WHEN "000",
                 reg1 WHEN "001",
                 reg2 WHEN "010",
                 reg3 WHEN "011",
                 reg4 WHEN "100",
                 reg5 WHEN "101",
                 reg6 WHEN "110",
                 reg7 WHEN "111",
                 (others => '0') WHEN OTHERS;
END register_file_nDFF;

