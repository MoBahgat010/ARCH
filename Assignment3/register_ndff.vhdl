library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY register_file IS
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
END ENTITY register_file;

ARCHITECTURE register_file_nDFF OF register_file is
  COMPONENT my_nDFF
    GENERIC ( n : integer := 8);
    PORT(
        clk : IN std_logic;
        reset : IN std_logic;
        d : IN std_logic_vector(n-1 DOWNTO 0);
        q : OUT std_logic_vector(n-1 DOWNTO 0)
    );
  END COMPONENT;
  TYPE reg_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(7 downto 0);
  SIGNAL reg_in, reg_out : reg_type;
BEGIN
  loop0:for i IN 0 to 7 GENERATE
    reg_inst : my_nDFF
      GENERIC MAP ( n => 8)
      PORT MAP (
        clk => clk,
        reset => reset,
        d => reg_in(i),
        q => reg_out(i)
      );
  end generate;
  process(write_enable, wr_addr, data_in, reg_out) IS
  BEGIN
  IF write_enable = '0' THEN
      reg_in <= reg_out;
  ELSE
      loop1:FOR i IN 0 TO 7 LOOP
          IF i = to_integer(unsigned(wr_addr)) THEN
              reg_in(i) <= data_in;
          ELSE
              reg_in(i) <= reg_out(i);
          END IF;
      END LOOP;
  END IF;
  END PROCESS;

 data_out0 <= reg_out(to_integer(unsigned(rd_addr0)));
 data_out1 <= reg_out(to_integer(unsigned(rd_addr1)));
END register_file_nDFF;

