add wave -position insertpoint  \
sim:/portc/a \
sim:/portc/cin \
sim:/portc/sel \
sim:/portc/f \
sim:/portc/cout
force -freeze sim:/portc/sel 00 0
force -freeze sim:/portc/a 11110101 0
run
force -freeze sim:/portc/sel 01 0
run
force -freeze sim:/portc/sel 10 0
force -freeze sim:/portc/cin 0 0
run
force -freeze sim:/portc/cin 1 0
run
force -freeze sim:/portc/sel 11 0
run
force -freeze sim:/portc/a 01111010 0
force -freeze sim:/portc/sel 01 0
run
