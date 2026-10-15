# Bitmap Display Setting
# Unit Width / Height in Pixels	: 4
# Display Width / Height	: 256
# Base address for display	: 0x10010000 (static data)
#
# Type in the Keyboard MMIO Simulator: Y = hit, N = stand

.eqv WHITE       0x00FFFFFF
.eqv BLACK       0x00000000
.eqv KEY_CONTROL 0xFFFF0000      # bit 0 = a key is ready
.eqv KEY_DATA    0xFFFF0004      # the typed character

.data
frame_buffer:   .space 16384     # 64 x 64 units, must stay first (0x10010000)

# One card of each rank per suit: 1 = A, 11 = J, 12 = Q, 13 = K
deck:           .byte 1,2,3,4,5,6,7,8,9,10,11,12,13
                .byte 1,2,3,4,5,6,7,8,9,10,11,12,13
                .byte 1,2,3,4,5,6,7,8,9,10,11,12,13
                .byte 1,2,3,4,5,6,7,8,9,10,11,12,13
cards_left:     .word 52
player_hand:    .space 12
player_count:   .word 0
dealer_hand:    .space 12
dealer_count:   .word 0

# Bitmap strings: '#' = black, '.' = white, '/' = next row
# Every glyph is 3x5, so each string is 20 bytes apart
font_chars:     .asciiz "0123456789ADEIJKLNOQRSTUWY:! "
font_glyphs:    .asciiz "###/#.#/#.#/#.#/###"   # 0
                .asciiz ".#./##./.#./.#./###"   # 1
                .asciiz "###/..#/###/#../###"   # 2
                .asciiz "###/..#/###/..#/###"   # 3
                .asciiz "#.#/#.#/###/..#/..#"   # 4
                .asciiz "###/#../###/..#/###"   # 5
                .asciiz "###/#../###/#.#/###"   # 6
                .asciiz "###/..#/..#/..#/..#"   # 7
                .asciiz "###/#.#/###/#.#/###"   # 8
                .asciiz "###/#.#/###/..#/###"   # 9
                .asciiz ".#./#.#/###/#.#/#.#"   # A
                .asciiz "##./#.#/#.#/#.#/##."   # D
                .asciiz "###/#../###/#../###"   # E
                .asciiz "###/.#./.#./.#./###"   # I
                .asciiz "..#/..#/..#/#.#/.#."   # J
                .asciiz "#.#/#.#/##./#.#/#.#"   # K
                .asciiz "#../#../#../#../###"   # L
                .asciiz "##./#.#/#.#/#.#/#.#"   # N
                .asciiz ".#./#.#/#.#/#.#/.#."   # O
                .asciiz ".#./#.#/#.#/##./.##"   # Q
                .asciiz "##./#.#/##./#.#/#.#"   # R
                .asciiz ".##/#../.#./..#/##."   # S
                .asciiz "###/.#./.#./.#./.#."   # T
                .asciiz "#.#/#.#/#.#/#.#/###"   # U
                .asciiz "#.#/#.#/###/###/#.#"   # W
                .asciiz "#.#/#.#/.#./.#./.#."   # Y
                .asciiz ".../.#./.../.#./..."   # :
                .asciiz ".#./.#./.#./.../.#."   # !
                .asciiz ".../.../.../.../..."   # space

card_outline:   .ascii  "###########/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .ascii  "#.........#/"
                .asciiz "###########"

# Card labels for ranks 1-13, 3 bytes apart
rank_labels:    .asciiz "A\0", "2\0", "3\0", "4\0", "5\0", "6\0", "7\0"
                .asciiz "8\0", "9\0", "10", "J\0", "Q\0", "K\0"

number_text:    .asciiz "  "
text_dealer:    .asciiz "DEALER:"
text_you:       .asciiz "YOU:"
text_win:       .asciiz "YOU WIN!"
text_lose:      .asciiz "YOU LOSE!"
text_tie:       .asciiz "TIE!"
msg_prompt:     .asciiz "Hit or stand? (Y/N): "
msg_invalid:    .asciiz "Invalid key, press Y or N.\n"

.text
Main:
    jal ClearScreen
    li $a0, 2                    # "DEALER: 0"
    li $a1, 2
    la $a2, text_dealer
    jal DrawText
    li $a0, 34
    li $a1, 2
    li $a2, 0
    jal DrawNumber
    li $a0, 2                    # "YOU:"
    li $a1, 58
    la $a2, text_you
    jal DrawText

    jal HitPlayer                # opening hand
    jal HitPlayer
    move $s0, $v0                # player total

PlayerTurn:
    bge $s0, 21, DealerTurn      # 21 or bust ends the turn
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

    ori $t0, $t0, 0x20           # lowercase, so Y and y both work
    beq $t0, 'y', PlayerHit
    beq $t0, 'n', DealerTurn
    li $v0, 4
    la $a0, msg_invalid
    syscall
    j PlayerTurn

PlayerHit:
    jal HitPlayer
    move $s0, $v0
    j PlayerTurn

DealerTurn:
    bgt $s0, 21, PlayerLoses     # player bust, dealer doesn't need to play
    li $s1, 0                    # dealer total
DealerLoop:
    bge $s1, 19, CompareHands    # 19+ (or bust) stands
    ble $s1, 13, DealerHit       # 0-13 always hits
    li $v0, 42                   # 14-18: coin flip
    li $a0, 0
    li $a1, 2
    syscall
    beqz $a0, CompareHands
DealerHit:
    jal HitDealer
    move $s1, $v0
    j DealerLoop

CompareHands:
    bgt $s1, 21, PlayerWins
    bgt $s0, $s1, PlayerWins
    blt $s0, $s1, PlayerLoses
    la $a2, text_tie
    j GameOver
PlayerWins:
    la $a2, text_win
    j GameOver
PlayerLoses:
    la $a2, text_lose
GameOver:
    li $a1, 14
    jal DrawCenteredText

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


# ClearScreen() - fill the display with white
ClearScreen:
    li $t0, 0
    li $t1, WHITE
ClearScreenLoop:
    sw $t1, frame_buffer($t0)
    addi $t0, $t0, 4
    blt $t0, 16384, ClearScreenLoop
    jr $ra


# DealCard() -> $v0 = rank 1-13, removed from the shared deck
DealCard:
    lw $t0, cards_left
    li $v0, 42                   # random index in [0, cards_left)
    li $a0, 0
    move $a1, $t0
    syscall
    lb $v0, deck($a0)
    addi $t0, $t0, -1            # move the last card into the gap
    lb $t1, deck($t0)
    sb $t1, deck($a0)
    sw $t0, cards_left
    jr $ra


# HandValue($a0 = hand, $a1 = card count) -> $v0 = best total
HandValue:
    li $v0, 0
    li $t1, 0                    # 1 if the hand has an ace
HandValueLoop:
    beqz $a1, HandValueAce
    lb $t0, 0($a0)
    ble $t0, 10, HandValueAdd
    li $t0, 10                   # J, Q, K
HandValueAdd:
    add $v0, $v0, $t0
    bne $t0, 1, HandValueNext
    li $t1, 1
HandValueNext:
    addi $a0, $a0, 1
    addi $a1, $a1, -1
    j HandValueLoop
HandValueAce:
    beqz $t1, HandValueDone
    bgt $v0, 11, HandValueDone
    addi $v0, $v0, 10            # one ace counts as 11
HandValueDone:
    jr $ra


# HitPlayer() -> $v0 = player total; deals, draws the card and the score
HitPlayer:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    jal DealCard
    lw $s0, player_count
    sb $v0, player_hand($s0)

    move $a2, $v0                # 5 cards per row, 12 units apart
    li $t0, 5
    div $s0, $t0
    mflo $t1                     # row
    mfhi $t2                     # column
    li $t0, 12
    mul $a0, $t2, $t0
    addi $a0, $a0, 2
    mul $a1, $t1, $t0
    addi $a1, $a1, 22
    jal DrawCard

    addi $s0, $s0, 1
    sw $s0, player_count
    la $a0, player_hand
    move $a1, $s0
    jal HandValue
    move $s0, $v0

    li $a0, 22                   # "YOU: n"
    li $a1, 58
    move $a2, $s0
    jal DrawNumber
    move $v0, $s0

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra


# HitDealer() -> $v0 = dealer total; deals and draws the score
HitDealer:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    jal DealCard
    lw $s0, dealer_count
    sb $v0, dealer_hand($s0)
    addi $s0, $s0, 1
    sw $s0, dealer_count
    la $a0, dealer_hand
    move $a1, $s0
    jal HandValue
    move $s0, $v0

    li $a0, 34                   # "DEALER: n"
    li $a1, 2
    move $a2, $s0
    jal DrawNumber
    move $v0, $s0

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra


# DrawCard($a0 = x, $a1 = y, $a2 = rank) - 11x11 card with its label
DrawCard:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    la $a2, card_outline
    jal DrawBitmap

    addi $t0, $s2, -1
    mul $t0, $t0, 3
    la $a2, rank_labels
    add $a2, $a2, $t0
    addi $a0, $s0, 4             # one character is centered at +4
    lb $t1, 1($a2)
    beqz $t1, DrawCardLabel
    addi $a0, $s0, 2             # "10" is centered at +2
DrawCardLabel:
    addi $a1, $s1, 3
    jal DrawText

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra


# DrawNumber($a0 = x, $a1 = y, $a2 = number 0-99) - always 2 characters wide
DrawNumber:
    li $t0, 10
    div $a2, $t0
    mflo $t1                     # tens
    mfhi $t2                     # ones
    la $t3, number_text
    addi $t2, $t2, '0'
    beqz $t1, DrawNumberOne
    addi $t1, $t1, '0'
    sb $t1, 0($t3)
    sb $t2, 1($t3)
    j DrawNumberText
DrawNumberOne:
    sb $t2, 0($t3)
    li $t1, ' '                  # blank out an old second digit
    sb $t1, 1($t3)
DrawNumberText:
    move $a2, $t3
    j DrawText


# DrawCenteredText($a1 = y, $a2 = text)
DrawCenteredText:
    li $t0, 0                    # text length
DrawCenteredTextLength:
    add $t1, $a2, $t0
    lb $t1, 0($t1)
    beqz $t1, DrawCenteredTextStart
    addi $t0, $t0, 1
    j DrawCenteredTextLength
DrawCenteredTextStart:
    sll $t0, $t0, 2              # x = (64 - (4 * length - 1)) / 2
    li $a0, 65
    sub $a0, $a0, $t0
    sra $a0, $a0, 1
    j DrawText


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
    move $a1, $s1
    move $a2, $v0
    jal DrawBitmap
    addi $s0, $s0, 4             # 3 wide + 1 space
    addi $s2, $s2, 1
    j DrawTextLoop
DrawTextDone:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra


# GetGlyph($a0 = character) -> $v0 = its bitmap string (space if unknown)
GetGlyph:
    li $t0, 0
GetGlyphLoop:
    lb $t1, font_chars($t0)
    beq $t1, $a0, GetGlyphFound
    beqz $t1, GetGlyphMissing
    addi $t0, $t0, 1
    j GetGlyphLoop
GetGlyphMissing:
    addi $t0, $t0, -1            # last glyph is the space
GetGlyphFound:
    mul $t0, $t0, 20
    la $v0, font_glyphs
    add $v0, $v0, $t0
    jr $ra


# DrawBitmap($a0 = x, $a1 = y, $a2 = bitmap string)
DrawBitmap:
    move $t0, $a0                # current x
DrawBitmapLoop:
    lb $t1, 0($a2)
    beqz $t1, DrawBitmapDone
    addi $a2, $a2, 1
    bne $t1, '/', DrawBitmapPixel
    move $t0, $a0                # back to the left edge
    addi $a1, $a1, 1             # of the next row
    j DrawBitmapLoop
DrawBitmapPixel:
    li $t2, BLACK
    beq $t1, '#', DrawBitmapSet
    li $t2, WHITE
DrawBitmapSet:
    sll $t3, $a1, 6              # (y * 64 + x) * 4 bytes
    add $t3, $t3, $t0
    sll $t3, $t3, 2
    sw $t2, frame_buffer($t3)
    addi $t0, $t0, 1
    j DrawBitmapLoop
DrawBitmapDone:
    jr $ra
