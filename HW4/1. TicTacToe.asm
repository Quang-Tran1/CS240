# Bitmap Display Setting
# Unit Width / Height in Pixels	: 8
# Display Width / Height	: 256
# Base address for display	: 0x10010000 (static data)

.eqv WHITE       0x00FFFFFF
.eqv BLACK       0x00000000
.eqv KEY_CONTROL 0xFFFF0000      # bit 0 = a key is ready
.eqv KEY_DATA    0xFFFF0004      # the typed character

.data
frame_buffer:   .space 4096      # 32 x 32 units, must stay first (0x10010000)
board:          .space 9         # 0 = empty, 1 = X, 2 = O
player_symbols: .ascii " XO"
sprite_x:       .byte 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0, 0,1,0,1,0, 1,0,0,0,1
sprite_o:       .byte 1,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,1
win_lines:      .byte 0,1,2, 3,4,5, 6,7,8, 0,3,6, 1,4,7, 2,5,8, 0,4,8, 2,4,6
msg_player:     .asciiz "Player "
msg_prompt:     .asciiz ", pick a square (1-9): "
msg_invalid:    .asciiz "Invalid move, try again.\n"
msg_wins:       .asciiz " wins!\n"
msg_draw:       .asciiz "It's a draw!\n"

.text
Main:
    jal DrawBoard
    li $s0, 1                    # current player (1 = X, 2 = O)
    li $s1, 0                    # moves made

GameLoop:
    li $v0, 4                    # "Player X, pick a square (1-9): "
    la $a0, msg_player
    syscall
    lb $a0, player_symbols($s0)
    li $v0, 11
    syscall
    li $v0, 4
    la $a0, msg_prompt
    syscall

    jal ReadKey
    move $t0, $v0
    li $v0, 11                   # echo the key
    move $a0, $t0
    syscall
    li $a0, '\n'
    syscall

    addi $t0, $t0, -49           # '1'..'9' -> 0..8
    bltu $t0, 9, CheckSquare     # unsigned, so anything below '1' fails too
    j InvalidMove
CheckSquare:
    lb $t1, board($t0)
    bnez $t1, InvalidMove
    sb $s0, board($t0)

    move $a0, $t0
    move $a1, $s0
    jal DrawMark

    move $a0, $s0
    jal CheckWin
    bnez $v0, GameWon

    addi $s1, $s1, 1
    beq $s1, 9, GameDraw

    xori $s0, $s0, 3             # swap players: 1 <-> 2
    j GameLoop

InvalidMove:
    li $v0, 4
    la $a0, msg_invalid
    syscall
    j GameLoop

GameWon:
    lb $a0, player_symbols($s0)
    li $v0, 11
    syscall
    li $v0, 4
    la $a0, msg_wins
    syscall
    j Exit

GameDraw:
    li $v0, 4
    la $a0, msg_draw
    syscall

Exit:
    li $v0, 10
    syscall


# ReadKey() -> $v0 = character typed in the MMIO keyboard
ReadKey:
    li $t0, KEY_CONTROL
ReadKeyWait:
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, ReadKeyWait
    lw $v0, KEY_DATA
    jr $ra


# SetPixel($a0 = x, $a1 = y, $a2 = color)
SetPixel:
    sll $t0, $a1, 5              # y * 32
    add $t0, $t0, $a0            # + x
    sll $t0, $t0, 2              # * 4 bytes per unit
    sw $a2, frame_buffer($t0)
    jr $ra


# DrawBoard() - white background with two black lines each way
DrawBoard:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    li $t0, 0
    li $t1, WHITE
DrawBoardFill:
    sw $t1, frame_buffer($t0)
    addi $t0, $t0, 4
    blt $t0, 4096, DrawBoardFill

    li $s0, 0                    # position along the line
    li $a2, BLACK
DrawBoardLines:
    li $a0, 10                   # vertical lines at x = 10 and 21
    move $a1, $s0
    jal SetPixel
    li $a0, 21
    jal SetPixel
    move $a0, $s0                # horizontal lines at y = 10 and 21
    li $a1, 10
    jal SetPixel
    li $a1, 21
    jal SetPixel
    addi $s0, $s0, 1
    blt $s0, 32, DrawBoardLines

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra


# DrawMark($a0 = square 0-8, $a1 = player 1 or 2)
DrawMark:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)

    li $t0, 3
    div $a0, $t0
    mflo $t1                     # row
    mfhi $t2                     # column
    li $t0, 11                   # each square is 10 units + 1 unit line
    mul $s0, $t2, $t0
    addi $s0, $s0, 2             # left x of the 5x5 sprite
    mul $s1, $t1, $t0
    addi $s1, $s1, 3             # top y of the 5x5 sprite

    la $s2, sprite_x
    beq $a1, 1, DrawMarkStart
    la $s2, sprite_o
DrawMarkStart:
    li $a2, BLACK
    li $s3, 0                    # sprite row
DrawMarkRow:
    li $s4, 0                    # sprite column
DrawMarkColumn:
    lb $t0, 0($s2)
    beqz $t0, DrawMarkNext
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    jal SetPixel
DrawMarkNext:
    addi $s2, $s2, 1
    addi $s4, $s4, 1
    blt $s4, 5, DrawMarkColumn
    addi $s3, $s3, 1
    blt $s3, 5, DrawMarkRow

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra


# CheckWin($a0 = player) -> $v0 = 1 if that player has three in a row
CheckWin:
    la $t0, win_lines
    li $t1, 8                    # lines left to check
CheckWinLine:
    lb $t2, 0($t0)
    lb $t3, board($t2)
    bne $t3, $a0, CheckWinNext
    lb $t2, 1($t0)
    lb $t3, board($t2)
    bne $t3, $a0, CheckWinNext
    lb $t2, 2($t0)
    lb $t3, board($t2)
    bne $t3, $a0, CheckWinNext
    li $v0, 1
    jr $ra
CheckWinNext:
    addi $t0, $t0, 3
    addi $t1, $t1, -1
    bnez $t1, CheckWinLine
    li $v0, 0
    jr $ra
