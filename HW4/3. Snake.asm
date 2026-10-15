# Bitmap Display Setting
# Unit Width / Height in Pixels	: 2
# Display Width / Height	: 512
# Base address for display	: 0x10010000 (static data)
#
# Type in the Keyboard MMIO Simulator: W = up, A = left, S = down, D = right

.eqv KEY_CONTROL  0xFFFF0000     # bit 0 = a key is ready
.eqv KEY_DATA     0xFFFF0004     # the typed character
.eqv GRASS_LIGHT  0x00AAD751
.eqv GRASS_DARK   0x00A2D149
.eqv MODAL_BORDER 0x004A752C
.eqv MODAL_GREEN  0x00578A34
.eqv TICK_MS      100            # pause between moves

.data
frame_buffer:   .space 262144    # 256 x 256 units, must stay first (0x10010000)

# The board is 16 x 16 cells of 16 x 16 units, cell = row * 16 + column
grid:           .space 256       # 0 = empty, else 1 + direction to the next segment
direction_keys: .asciiz "dsaw"   # index = direction: 0 right, 1 down, 2 left, 3 up
direction_dx:   .byte 1, 0, -1, 0
direction_dy:   .byte 0, 1, 0, -1

# Bitmap strings: one character per unit, '.' = see-through, '/' = next row
palette_keys:   .asciiz "BWKRHSGs#"
palette_colors: .word 0x004F7CF6     # B snake
                .word 0x00FFFFFF     # W eye
                .word 0x001C469E     # K pupil
                .word 0x00E7471D     # R apple
                .word 0x00EE755C     # H apple shine
                .word 0x00976E4C     # S stem
                .word 0x0049C527     # G leaf
                .word 0x0094BD46     # s shadow
                .word 0x00FFFFFF     # # text

# Snake sprites face right and are turned by DrawBitmap
sprite_head:    .ascii  ".......WWW....../"
                .ascii  "BBBBBBWWWWWBB.../"
                .ascii  "BBBBBWWWWKKKBB../"
                .ascii  "BBBBBWWWWKKKBBB./"
                .ascii  "BBBBBWWWWKKKBBB./"
                .ascii  "BBBBBBWWWWWBBBBB/"
                .ascii  "BBBBBBBWWWBBBBKB/"
                .ascii  "BBBBBBBBBBBBBBBB/"
                .ascii  "BBBBBBBBBBBBBBBB/"
                .ascii  "BBBBBBBWWWBBBBKB/"
                .ascii  "BBBBBBWWWWWBBBBB/"
                .ascii  "BBBBBWWWWKKKBBB./"
                .ascii  "BBBBBWWWWKKKBBB./"
                .ascii  "BBBBBWWWWKKKBB../"
                .ascii  "BBBBBBWWWWWBB.../"
                .asciiz ".......WWW......"

sprite_tail:    .ascii  "................/"
                .ascii  ".....BBBBBBBBBBB/"
                .ascii  "...BBBBBBBBBBBBB/"
                .ascii  "..BBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  "..BBBBBBBBBBBBBB/"
                .ascii  "...BBBBBBBBBBBBB/"
                .ascii  ".....BBBBBBBBBBB/"
                .asciiz "................"

# Half a body segment; a body cell is one half toward each neighbor
sprite_body:    .ascii  "................/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .ascii  ".BBBBBBBBBBBBBBB/"
                .asciiz "................"

sprite_apple:   .ascii  ".......S.GGG..../"
                .ascii  ".......SGGG...../"
                .ascii  "......RRRR....../"
                .ascii  "....RRRRRRRR..../"
                .ascii  "...RHHRRRRRRR.../"
                .ascii  "...RHRRRRRRRR.../"
                .ascii  "..RRRRRRRRRRRR../"
                .ascii  "..RRRRRRRRRRRR../"
                .ascii  "..RRRRRRRRRRRR../"
                .ascii  "..RRRRRRRRRRRR../"
                .ascii  "..sRRRRRRRRRRs../"
                .ascii  "..sRRRRRRRRRRs../"
                .ascii  "...sRRRRRRRRs.../"
                .ascii  "...sssRRRRsss.../"
                .ascii  "....ssssssss..../"
                .asciiz "......ssss......"

# Font: the first character of each entry is the key, the rest is its bitmap
font:           .asciiz "Y#...#/#...#/.#.#./..#../..#../..#../..#.."
                .asciiz "o...../...../.###./#...#/#...#/#...#/.###."
                .asciiz "u...../...../#...#/#...#/#...#/#...#/.###."
                .asciiz "l#/#/#/#/#/#/#"
                .asciiz "s...../...../.####/#..../.###./....#/####."
                .asciiz "e...../...../.###./#...#/#####/#..../.###."
                .asciiz "w...../...../#...#/#...#/#.#.#/#.#.#/.#.#."
                .asciiz "i#/./#/#/#/#/#"
                .asciiz "n...../...../####./#...#/#...#/#...#/#...#"
                .asciiz "!#/#/#/#/#/./#"
                .asciiz "0.###./#...#/#...#/#...#/#...#/#...#/.###."
                .asciiz "1..#../.##../..#../..#../..#../..#../.###."
                .asciiz "2.###./#...#/....#/...#./..#../.#.../#####"
                .asciiz "3####./....#/....#/.###./....#/....#/####."
                .asciiz "4#...#/#...#/#...#/#####/....#/....#/....#"
                .asciiz "5#####/#..../####./....#/....#/#...#/.###."
                .asciiz "6.###./#..../#..../####./#...#/#...#/.###."
                .asciiz "7#####/....#/...#./..#../..#../..#../..#.."
                .asciiz "8.###./#...#/#...#/.###./#...#/#...#/.###."
                .asciiz "9.###./#...#/#...#/.####/....#/....#/.###."
                .asciiz "@...SGG./.RRSRR./RHRRRRR/RRRRRRR/RRRRRRR/.RRRRR./..RRR.."
                .asciiz " ..."
                .byte 0                      # end of font

# Rectangles: x, y, width, height, color
cell_rect:      .word 0, 0, 16, 16, 0
modal_border:   .word 88, 108, 80, 40, MODAL_BORDER
modal_fill:     .word 90, 110, 76, 36, MODAL_GREEN

text_win:       .asciiz "You win!"
text_lose:      .asciiz "You lose!"
score_text:     .ascii  "@ "                 # apple icon, then the count
score_digits:   .space 4
msg_start:      .asciiz "Press W, A, S or D in the keyboard simulator to start.\n"

.text
Main:
    jal DrawBoard

    li $s0, 116                  # head (row 7, column 4)
    li $s1, 114                  # tail (row 7, column 2)
    li $s2, 0                    # direction: 0 right, 1 down, 2 left, 3 up
    li $s3, 0                    # direction of the last move
    li $s4, 3                    # length
    li $s5, 0                    # apples eaten
    li $s6, 124                  # apple (row 7, column 12)
    li $t0, 1                    # every segment points right (1 + direction)
    sb $t0, grid+114
    sb $t0, grid+115
    sb $t0, grid+116

    move $a0, $s1
    la $a1, sprite_tail
    li $a2, 0
    jal DrawSprite
    li $a0, 115
    li $a1, 0
    li $a2, 2
    jal DrawBody
    move $a0, $s0
    la $a1, sprite_head
    li $a2, 0
    jal DrawSprite
    move $a0, $s6
    la $a1, sprite_apple
    li $a2, 0
    jal DrawSprite

    li $v0, 4
    la $a0, msg_start
    syscall
WaitForStart:                    # the snake waits for the first direction key
    jal ReadKey
    move $a0, $v0
    jal KeyDirection
    bltz $v0, WaitForStart
    beq $v0, 2, WaitForStart     # can't start by turning around
    move $s2, $v0

GameLoop:
    li $v0, 32
    li $a0, TICK_MS
    syscall

    jal PollKey                  # turn, but never straight back
    move $a0, $v0
    jal KeyDirection
    bltz $v0, Move
    addi $t0, $s3, 2
    andi $t0, $t0, 3
    beq $v0, $t0, Move
    move $s2, $v0

Move:
    move $a0, $s0
    move $a1, $s2
    jal StepCell
    bltz $v0, GameLost           # hit a wall
    move $s7, $v0                # new head cell
    beq $s7, $s6, Eat

    move $a0, $s1                # erase the old tail
    jal ClearCell
    lb $a1, grid($s1)            # the tail follows the next segment
    addi $a1, $a1, -1
    sb $zero, grid($s1)
    move $a0, $s1
    jal StepCell
    move $s1, $v0
    move $a0, $s1
    la $a1, sprite_tail
    lb $a2, grid($s1)
    addi $a2, $a2, -1
    jal DrawCell
    j MoveHead

Eat:
    addi $s4, $s4, 1             # grow by keeping the tail
    addi $s5, $s5, 1

MoveHead:
    lb $t0, grid($s7)
    bnez $t0, GameLost           # ran into itself
    addi $t0, $s2, 1
    sb $t0, grid($s0)            # the old head points to the new head
    sb $t0, grid($s7)

    move $a0, $s0                # the old head becomes body
    move $a1, $s2
    addi $a2, $s3, 2             # back toward where it came from
    andi $a2, $a2, 3
    jal DrawBody
    move $a0, $s7
    la $a1, sprite_head
    move $a2, $s2
    jal DrawCell
    move $s0, $s7
    move $s3, $s2

    bne $s0, $s6, GameLoop       # no apple this move
    beq $s4, 256, GameWon        # the snake fills the board
    jal RandomEmptyCell
    move $s6, $v0
    move $a0, $s6
    la $a1, sprite_apple
    li $a2, 0
    jal DrawSprite
    j GameLoop

GameWon:
    la $a0, text_win
    j GameOver
GameLost:
    la $a0, text_lose
GameOver:
    move $a1, $s5
    jal ShowModal

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


# PollKey() -> $v0 = character typed, or 0 if no key is waiting
PollKey:
    li $v0, 0
    lw $t0, KEY_CONTROL
    andi $t0, $t0, 1
    beqz $t0, PollKeyDone
    lw $v0, KEY_DATA
PollKeyDone:
    jr $ra


# KeyDirection($a0 = character) -> $v0 = direction 0-3, or -1 if not W/A/S/D
KeyDirection:
    ori $a0, $a0, 0x20           # lowercase, so W and w both work
    li $v0, 0
KeyDirectionLoop:
    lb $t0, direction_keys($v0)
    beq $t0, $a0, KeyDirectionDone
    addi $v0, $v0, 1
    blt $v0, 4, KeyDirectionLoop
    li $v0, -1
KeyDirectionDone:
    jr $ra


# StepCell($a0 = cell, $a1 = direction) -> $v0 = neighbor cell, or -1 off the board
StepCell:
    andi $t0, $a0, 15
    lb $t1, direction_dx($a1)
    add $t0, $t0, $t1            # column
    srl $t2, $a0, 4
    lb $t1, direction_dy($a1)
    add $t2, $t2, $t1            # row
    li $v0, -1
    bgeu $t0, 16, StepCellDone   # unsigned, so -1 is off the board too
    bgeu $t2, 16, StepCellDone
    sll $v0, $t2, 4
    add $v0, $v0, $t0
StepCellDone:
    jr $ra


# RandomEmptyCell() -> $v0 = a random cell the snake is not on
RandomEmptyCell:
    li $v0, 42
    li $a0, 0
    li $a1, 256
    syscall
    lb $t0, grid($a0)
    bnez $t0, RandomEmptyCell
    move $v0, $a0
    jr $ra


# FillRect($a0 = rectangle: x, y, width, height, color)
FillRect:
    lw $t0, 0($a0)               # left
    lw $t1, 4($a0)               # top
    lw $t2, 8($a0)
    add $t2, $t2, $t0            # right
    lw $t3, 12($a0)
    add $t3, $t3, $t1            # bottom
    lw $t4, 16($a0)              # color
FillRectRow:
    move $t5, $t0
FillRectColumn:
    sll $t6, $t1, 8              # (y * 256 + x) * 4 bytes
    add $t6, $t6, $t5
    sll $t6, $t6, 2
    sw $t4, frame_buffer($t6)
    addi $t5, $t5, 1
    blt $t5, $t2, FillRectColumn
    addi $t1, $t1, 1
    blt $t1, $t3, FillRectRow
    jr $ra


# ClearCell($a0 = cell) - paint the checkered grass back
ClearCell:
    andi $t0, $a0, 15
    sll $t0, $t0, 4              # x = column * 16
    andi $t1, $a0, 0xF0          # y = row * 16
    srl $t2, $a0, 4
    xor $t2, $t2, $a0
    andi $t2, $t2, 1             # (row + column) is odd -> dark
    li $t3, GRASS_LIGHT
    beqz $t2, ClearCellFill
    li $t3, GRASS_DARK
ClearCellFill:
    la $a0, cell_rect
    sw $t0, 0($a0)
    sw $t1, 4($a0)
    sw $t3, 16($a0)
    j FillRect


# DrawBoard() - the whole checkered field
DrawBoard:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    li $s0, 0
DrawBoardLoop:
    move $a0, $s0
    jal ClearCell
    addi $s0, $s0, 1
    blt $s0, 256, DrawBoardLoop
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra


# DrawSprite($a0 = cell, $a1 = 16x16 bitmap, $a2 = direction) - over what is there
DrawSprite:
    move $a3, $a2
    move $a2, $a1
    andi $a1, $a0, 0xF0          # y = row * 16
    andi $a0, $a0, 15
    sll $a0, $a0, 4              # x = column * 16
    j DrawBitmap


# DrawCell($a0 = cell, $a1 = 16x16 bitmap, $a2 = direction) - on fresh grass
DrawCell:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    jal ClearCell
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    addi $sp, $sp, 16
    j DrawSprite


# DrawBody($a0 = cell, $a1 = direction to next segment, $a2 = direction to previous)
DrawBody:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a2, 8($sp)
    move $a2, $a1
    la $a1, sprite_body
    jal DrawCell
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a2, 8($sp)
    addi $sp, $sp, 12
    la $a1, sprite_body
    j DrawSprite


# DrawBitmap($a0 = x, $a1 = y, $a2 = bitmap, $a3 = direction)
#   Directions 1-3 turn a 16x16 bitmap clockwise from facing right
DrawBitmap:
    li $t0, 0                    # column
    li $t1, 0                    # row
DrawBitmapLoop:
    lb $t2, 0($a2)
    beqz $t2, DrawBitmapDone
    addi $a2, $a2, 1
    bne $t2, '/', DrawBitmapColor
    li $t0, 0                    # next row
    addi $t1, $t1, 1
    j DrawBitmapLoop
DrawBitmapColor:
    beq $t2, '.', DrawBitmapNext
    li $t3, 0                    # find the character in the palette
DrawBitmapFind:
    lb $t4, palette_keys($t3)
    beq $t4, $t2, DrawBitmapTurn
    addi $t3, $t3, 1
    bnez $t4, DrawBitmapFind
    j DrawBitmapNext             # unknown character: skip
DrawBitmapTurn:
    move $t4, $t0                # right: (column, row)
    move $t5, $t1
    beq $a3, 0, DrawBitmapPlot
    li $t6, 15
    sub $t4, $t6, $t1            # down:  (15 - row, column)
    move $t5, $t0
    beq $a3, 1, DrawBitmapPlot
    sub $t4, $t6, $t0            # left:  (15 - column, 15 - row)
    sub $t5, $t6, $t1
    beq $a3, 2, DrawBitmapPlot
    move $t4, $t1                # up:    (row, 15 - column)
    sub $t5, $t6, $t0
DrawBitmapPlot:
    add $t4, $t4, $a0
    add $t5, $t5, $a1
    sll $t5, $t5, 8              # (y * 256 + x) * 4 bytes
    add $t5, $t5, $t4
    sll $t5, $t5, 2
    sll $t3, $t3, 2
    lw $t3, palette_colors($t3)
    sw $t3, frame_buffer($t5)
DrawBitmapNext:
    addi $t0, $t0, 1
    j DrawBitmapLoop
DrawBitmapDone:
    jr $ra


# GetGlyph($a0 = character) -> $v0 = its bitmap, $v1 = its width (space if unknown)
GetGlyph:
    la $v0, font
GetGlyphLoop:
    lb $t0, 0($v0)
    beqz $t0, GetGlyphMissing
    addi $v0, $v0, 1
    beq $t0, $a0, GetGlyphFound
GetGlyphSkip:                    # skip to the next entry
    lb $t0, 0($v0)
    addi $v0, $v0, 1
    bnez $t0, GetGlyphSkip
    j GetGlyphLoop
GetGlyphMissing:
    li $a0, ' '
    j GetGlyph
GetGlyphFound:
    li $v1, 0                    # width = length of the first row
GetGlyphWidth:
    add $t0, $v0, $v1
    lb $t0, 0($t0)
    beqz $t0, GetGlyphDone
    beq $t0, '/', GetGlyphDone
    addi $v1, $v1, 1
    j GetGlyphWidth
GetGlyphDone:
    jr $ra


# DrawText($a0 = x, $a1 = y, $a2 = text)
DrawText:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
DrawTextLoop:
    lb $a0, 0($s2)
    beqz $a0, DrawTextDone
    jal GetGlyph
    move $a0, $s0
    add $s0, $s0, $v1
    addi $s0, $s0, 1             # glyph width + 1 space
    move $a1, $s1
    move $a2, $v0
    li $a3, 0
    jal DrawBitmap
    addi $s2, $s2, 1
    j DrawTextLoop
DrawTextDone:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra


# TextWidth($a0 = text) -> $v0 = width in units
TextWidth:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    move $s0, $a0
    li $s1, -1                   # no space after the last glyph
TextWidthLoop:
    lb $a0, 0($s0)
    beqz $a0, TextWidthDone
    jal GetGlyph
    add $s1, $s1, $v1
    addi $s1, $s1, 1
    addi $s0, $s0, 1
    j TextWidthLoop
TextWidthDone:
    move $v0, $s1
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra


# DrawCenteredText($a1 = y, $a2 = text)
DrawCenteredText:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    move $a0, $a2
    jal TextWidth
    li $a0, 256                  # x = (256 - width) / 2
    sub $a0, $a0, $v0
    sra $a0, $a0, 1
    lw $ra, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp)
    addi $sp, $sp, 12
    j DrawText


# IntToString($a0 = number, $a1 = buffer) - writes the digits and a null
IntToString:
    li $t1, 10
    move $t0, $a0
    move $t2, $a1
IntToStringCount:                # one slot per digit
    addi $t2, $t2, 1
    div $t0, $t1
    mflo $t0
    bnez $t0, IntToStringCount
    sb $zero, 0($t2)
IntToStringDigit:                # fill from the right
    addi $t2, $t2, -1
    div $a0, $t1
    mflo $a0
    mfhi $t3
    addi $t3, $t3, '0'
    sb $t3, 0($t2)
    bnez $a0, IntToStringDigit
    jr $ra


# ShowModal($a0 = title, $a1 = apples eaten)
ShowModal:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    move $s0, $a0
    move $s1, $a1

    la $a0, modal_border
    jal FillRect
    la $a0, modal_fill
    jal FillRect
    li $a1, 125
    move $a2, $s0
    jal DrawCenteredText
    move $a0, $s1
    la $a1, score_digits
    jal IntToString
    li $a1, 136
    la $a2, score_text
    jal DrawCenteredText

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
