add wave -position insertpoint  \
sim:/portd/a \
sim:/portd/cin \
sim:/portd/sel \
sim:/portd/f \
sim:/portd/cout
force -freeze sim:/portd/sel 00 0
force -freeze sim:/portd/a 11110101 0
run
force -freeze sim:/portd/sel 01 0
run
force -freeze sim:/portd/sel 10 0
force -freeze sim:/portd/cin 0 0
run
force -freeze sim:/portd/cin 1 0
run
force -freeze sim:/portd/sel 11 0
run
