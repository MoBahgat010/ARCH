add wave -position insertpoint  \
sim:/portb/a \
sim:/portb/b \
sim:/portb/sel \
sim:/portb/f \
sim:/portb/cout
force -freeze sim:/portb/sel 00 0
force -freeze sim:/portb/a 11110101 0
force -freeze sim:/portb/b 10101010 0
run
force -freeze sim:/portb/sel 01 0
run
force -freeze sim:/portb/sel 10 0
run
force -freeze sim:/portb/sel 11 0
run
