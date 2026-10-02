.data
FizzBuzz: .asciiz "FizzBuzz"
Fizz: .asciiz "Fizz"
Buzz: .asciiz "Buzz"

.text
li $t0, 1
li $t1, 101


loop:
j PrintItem
PrintItemEnd:

j PrintNewLine
PrintNewLineEnd:

addi $t0, $t0, 1
bne $t0, $t1, loop
j Exit



PrintItem:
rem $t2, $t0, 15
beq $t2, $zero, PrintFizzBuzz

rem $t2, $t0, 3
beq $t2, $zero, PrintFizz

rem $t2, $t0, 5
beq $t2, $zero, PrintBuzz

j PrintNumber

j PrintItemEnd



PrintFizzBuzz:
li $v0, 4
la $a0, FizzBuzz
syscall
j PrintItemEnd

PrintFizz:
li $v0, 4
la $a0, Fizz
syscall
j PrintItemEnd

PrintBuzz:
li $v0, 4
la $a0, Buzz
syscall
j PrintItemEnd

PrintNumber:
li $v0, 1
move $a0, $t0
syscall
j PrintItemEnd

PrintNewLine:
li $v0, 11
li $a0, '\n'
syscall 
j PrintNewLineEnd

Exit: