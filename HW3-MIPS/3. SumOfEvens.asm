li $t1, 2
li $t2, 102

loop:
add $t0, $t0, $t1
addi $t1, $t1, 2
bne $t1, $t2, loop