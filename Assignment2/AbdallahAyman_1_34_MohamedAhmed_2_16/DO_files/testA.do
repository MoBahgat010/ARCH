add wave -position insertpoint  \
sim:/porta/a \
sim:/porta/b \
sim:/porta/sel \
sim:/porta/cin \
sim:/porta/cout \
sim:/porta/f
force -freeze sim:/porta/a 00001111 0
force -freeze sim:/porta/b UUUUUUUU 0
force -freeze sim:/porta/cin 0 0
force -freeze sim:/porta/sel 00 0
run
force -freeze sim:/porta/cin 1 0
force -freeze sim:/porta/cin 0 0
force -freeze sim:/porta/sel 01 0
force -freeze sim:/porta/b 00000001 0
run
force -freeze sim:/porta/a 11111111 0
run
force -freeze sim:/porta/sel 10 0
run
force -freeze sim:/porta/sel 11 0
force -freeze sim:/porta/b UUUUUUUU 0
run
force -freeze sim:/porta/sel 00 0
force -freeze sim:/porta/cin 1 0
force -freeze sim:/porta/a 00001110 0
run
force -freeze sim:/porta/sel 01 0
force -freeze sim:/porta/a 11111111 0
force -freeze sim:/porta/b 00000001 0
run
force -freeze sim:/porta/a 00001111 0
force -freeze sim:/porta/sel 10 0
run
force -freeze sim:/porta/a 11110000 0
force -freeze sim:/porta/b UUUUUUUU 0
force -freeze sim:/porta/sel 11 0
run

