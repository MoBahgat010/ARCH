add wave -position insertpoint  \
sim:/alsu/a \
sim:/alsu/b \
sim:/alsu/cin \
sim:/alsu/sel \
sim:/alsu/f \
sim:/alsu/cout
force -freeze sim:/alsu/a 00001111 0
force -freeze sim:/alsu/b UUUUUUUU 0
force -freeze sim:/alsu/cin 0 0
force -freeze sim:/alsu/sel 0000 0
run
force -freeze sim:/alsu/cin 1 0
force -freeze sim:/alsu/cin 0 0
force -freeze sim:/alsu/sel 0001 0
force -freeze sim:/alsu/b 00000001 0
run
force -freeze sim:/alsu/a 11111111 0
run
force -freeze sim:/alsu/sel 0010 0
run
force -freeze sim:/alsu/sel 0011 0
force -freeze sim:/alsu/b UUUUUUUU 0
run
force -freeze sim:/alsu/sel 0000 0
force -freeze sim:/alsu/cin 1 0
force -freeze sim:/alsu/a 00001110 0
run
force -freeze sim:/alsu/sel 0001 0
force -freeze sim:/alsu/a 11111111 0
force -freeze sim:/alsu/b 00000001 0
run
force -freeze sim:/alsu/a 00001111 0
force -freeze sim:/alsu/sel 0010 0
run
force -freeze sim:/alsu/a 11110000 0
force -freeze sim:/alsu/b UUUUUUUU 0
force -freeze sim:/alsu/sel 0011 0
run

force -freeze sim:/alsu/a 11110101 0
force -freeze sim:/alsu/b 10101010 0
force -freeze sim:/alsu/sel 0100 0
run
force -freeze sim:/alsu/sel 0101 0
run
force -freeze sim:/alsu/sel 0110 0
run
force -freeze sim:/alsu/sel 0111 0
run
force -freeze sim:/alsu/b uuuuuuuu 0
force -freeze sim:/alsu/sel 1000 0
run
force -freeze sim:/alsu/sel 1001 0
run
force -freeze sim:/alsu/sel 1010 0
force -freeze sim:/alsu/cin 0 0
run
force -freeze sim:/alsu/cin 1 0
run
force -freeze sim:/alsu/sel 1011 0
run
force -freeze sim:/alsu/sel 1100 0
run
force -freeze sim:/alsu/sel 1101 0
run
force -freeze sim:/alsu/sel 1110 0
force -freeze sim:/alsu/cin 0 0
run
force -freeze sim:/alsu/cin 1 0
run
force -freeze sim:/alsu/sel 1111 0
run
force -freeze sim:/alsu/a 01111010 0
force -freeze sim:/alsu/sel 1001 0
run
