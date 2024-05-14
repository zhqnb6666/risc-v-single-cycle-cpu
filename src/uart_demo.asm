.data
num: .word 12
.text
li a7,5
ecall
addi a1, a0, 0
li a7, 5
ecall
addi a2, a0, 0
add a0, a1, a2
li a7, 1
