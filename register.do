add wave -position insertpoint  \
sim:/register_file/clk \
sim:/register_file/reset \
sim:/register_file/write_enable \
sim:/register_file/read_enable \
sim:/register_file/rd_addr0 \
sim:/register_file/rd_addr1 \
sim:/register_file/wr_addr \
sim:/register_file/data_in \
sim:/register_file/data_out0 \
sim:/register_file/data_out1 \
sim:/register_file/reg

# Clock 100 ps period (rising @ 50,150,250,... ps)
force -freeze sim:/register_file/clk 0 0, 1 {50 ps} -r 100 ps

# Init/reset
force -freeze sim:/register_file/reset 1
force -freeze sim:/register_file/write_enable 0
force -freeze sim:/register_file/read_enable 0
force -freeze sim:/register_file/rd_addr0 000
force -freeze sim:/register_file/rd_addr1 000
force -freeze sim:/register_file/wr_addr 000
force -freeze sim:/register_file/data_in 00000000
run 200 ps

# Deassert reset, enable reads globally
force -freeze sim:/register_file/reset 0
force -freeze sim:/register_file/read_enable 1
run 50 ps

# Write Reg(0)=0xFF (read happens same cycle)
force -freeze sim:/register_file/wr_addr 000
force -freeze sim:/register_file/data_in 11111111
force -freeze sim:/register_file/rd_addr0 000
force -freeze sim:/register_file/rd_addr1 000
force -freeze sim:/register_file/write_enable 1
run 100 ps
force -freeze sim:/register_file/write_enable 0

# Write Reg(1)=0x11 (read back Reg0 in same cycle)
force -freeze sim:/register_file/wr_addr 001
force -freeze sim:/register_file/data_in 00010001
force -freeze sim:/register_file/rd_addr0 000   ;# expect 0xFF on this edge
force -freeze sim:/register_file/rd_addr1 000
force -freeze sim:/register_file/write_enable 1
run 100 ps
force -freeze sim:/register_file/write_enable 0

# Write Reg(7)=0x90 (read back Reg1/Reg0 same cycle)
force -freeze sim:/register_file/wr_addr 111
force -freeze sim:/register_file/data_in 10010000
force -freeze sim:/register_file/rd_addr0 001   ;# expect 0x11
force -freeze sim:/register_file/rd_addr1 000   ;# expect 0xFF
force -freeze sim:/register_file/write_enable 1
run 100 ps
force -freeze sim:/register_file/write_enable 0

# Write Reg(3)=0x08 (read back Reg7/Reg1 same cycle)
force -freeze sim:/register_file/wr_addr 011
force -freeze sim:/register_file/data_in 00001000
force -freeze sim:/register_file/rd_addr0 111   ;# expect 0x90
force -freeze sim:/register_file/rd_addr1 001   ;# expect 0x11
force -freeze sim:/register_file/write_enable 1
run 100 ps
force -freeze sim:/register_file/write_enable 0

# Read Reg(1) on port0 and Reg(7) on port1 AND write Reg(4)=0x03 (same cycle)
force -freeze sim:/register_file/wr_addr 100
force -freeze sim:/register_file/data_in 00000011
force -freeze sim:/register_file/rd_addr0 001   ;# expect 0x11
force -freeze sim:/register_file/rd_addr1 111   ;# expect 0x90
force -freeze sim:/register_file/write_enable 1
run 100 ps
force -freeze sim:/register_file/write_enable 0

# Read Reg(2) on port0 (0x00) and Reg(3) on port1 (0x08)
force -freeze sim:/register_file/rd_addr0 010
force -freeze sim:/register_file/rd_addr1 011
run 100 ps

# Read Reg(4) on port0 (0x03) and Reg(5) on port1 (0x00)
force -freeze sim:/register_file/rd_addr0 100
force -freeze sim:/register_file/rd_addr1 101
run 100 ps

# Read Reg(6) on port0 and Reg(0) on port1 AND write Reg(0)=0x01 (same cycle)
force -freeze sim:/register_file/wr_addr 000
force -freeze sim:/register_file/data_in 00000001
force -freeze sim:/register_file/rd_addr0 110   ;# expect 0x00
force -freeze sim:/register_file/rd_addr1 000   ;# expect 0xFF (old) on this edge
force -freeze sim:/register_file/write_enable 1
run 100 ps
force -freeze sim:/register_file/write_enable 0

# Read back Reg(0)=0x01
force -freeze sim:/register_file/rd_addr0 000
force -freeze sim:/register_file/rd_addr1 000
run 100 ps