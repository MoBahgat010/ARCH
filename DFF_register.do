add wave -radix hex -position insertpoint  \
sim:/register_file/clk \
sim:/register_file/reset \
sim:/register_file/write_enable \
sim:/register_file/rd_addr0 \
sim:/register_file/rd_addr1 \
sim:/register_file/wr_addr \
sim:/register_file/data_in \
sim:/register_file/data_out0 \
sim:/register_file/data_out1
force -freeze sim:/register_file/clk 0 1, 1 {50 ps} -r 100
force -freeze sim:/register_file/reset 1 0
force -freeze sim:/register_file/rd_addr0 000 0
force -freeze sim:/register_file/rd_addr1 000 0
run
force -freeze sim:/register_file/reset 0 0
force -freeze sim:/register_file/write_enable 1 0
force -freeze sim:/register_file/wr_addr 000 0
force -freeze sim:/register_file/data_in 11111111 0
run
force -freeze sim:/register_file/wr_addr 001 0
force -freeze sim:/register_file/data_in 00010001 0
run
force -freeze sim:/register_file/wr_addr 111 0
force -freeze sim:/register_file/data_in 10010000 0
run
force -freeze sim:/register_file/wr_addr 011 0
force -freeze sim:/register_file/data_in 00001000 0
run
force -freeze sim:/register_file/wr_addr 100 0
force -freeze sim:/register_file/data_in 00000011 0
force -freeze sim:/register_file/rd_addr0 001 0
force -freeze sim:/register_file/rd_addr1 111 0
run
force -freeze sim:/register_file/write_enable 0 0
force -freeze sim:/register_file/rd_addr0 010 0
force -freeze sim:/register_file/rd_addr1 011 0
run
force -freeze sim:/register_file/rd_addr0 100 0
force -freeze sim:/register_file/rd_addr1 101 0
run
force -freeze sim:/register_file/rd_addr0 110 0
force -freeze sim:/register_file/rd_addr1 000 0
force -freeze sim:/register_file/write_enable 1 0
force -freeze sim:/register_file/data_in 00000001 0
force -freeze sim:/register_file/wr_addr 000 0
run
