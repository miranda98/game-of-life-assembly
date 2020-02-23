    .data

N:  .word 10  # gives board dimensions
eol: .asciiz "\n"

board:
    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
    .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
    .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

# int neighbours (int i, int j)
# {
#     int nn = 0;
#     for (int x = -1; x <= 1; x++) {
#         for (int y = -1; y <= 1; y++) {
#             // What if it's on a edge
#             if (i + x < 0 || i + x > N - 1) continue;
#             if (j + y < 0 || j + y > N - 1) continue;

#             // This is pointing to the cell you are investigating
#             // A cell doesnt count itself as a neighbour
#             if (x == 0 && y == 0) continue;

#             // So at this point, we are dealing with 
#             // real neighbour cells
#             // is it alive? if so, count it
#             if (board[i + x][j + y] == 1) nn++;
#         }
#     }
#     return nn;
# }

neighbours:
# set up stack frame
sw  $fp, -4($sp)    # push $fp onto stack
la  $fp, -4($sp)    # set up $fp for this function
sw  $ra, -4($fp)    # save return address
sw  $s0, -8($fp)    # $s0 = N
sw  $s1, -12($fp)   # $s1 = nn
sw  $s2, -16($fp)   # $s2 = x
sw  $s3, -20($fp)   # $s3 = y
sw  $s4, -24($fp)   # $s4 = i
sw  $s5, -28($fp)   # $s5 = j
addi    $sp, $sp, -32   # move $sp to top of stack

move    $s4, $a0    # load i into $s4
move    $s5, $a1    # loat j into $s5

lw  $s0, N      # $s0 = N
li  $s1, 0      # int nn = 0
li  $s2, -1     # int x = -1
li  $t0, 1      # $t0 = 1


# for (int x = -1, x <= 1; x++)
loop_x:
    bgt $s2, $t0, end_loop_x     # if x > 1, jump to end_loop_x

    li  $s3, -1             # int y = -1;
loop_y:
    bgt $s3, $t0, end_loop_y     # (bgt) if y > 1, jump to end_loop_y

# What if it's on a edge
# if (i + x < 0 || i + x > N - 1) continue;
if_1:
    add     $t1, $s4, $s2       # $t1 = i + x
    bgez    $t1, if_2           # if $t1 >= 0, jump to next condition
    j       y_increment
    sub     $t2, $s0, 1         # $t2 = N - 1
    bge     $t2, $s4, if_2      # if $t2 >= $t1, jump to next condition
    j       y_increment

if_2: # if (j + y < 0 || j + y > N - 1) continue;
    add     $t3, $s5, $s3       # $t3 = j + y
    bgez    $t3, if_3           # if $t3 >= 0, jump to condition
    j       y_increment
                                # $t2 = N-1 ( as above )
    bge     $t2, $t3, if_3      # if $t2 >= $t3, jump to condition
    j       y_increment

# This is pointing to the cell you are investigating
# A cell doesnt count itself as a neighbour
if_3: # if (x == 0 && y == 0) continue;
    bnez    $s2, if_4         # (bnez) if x != 0, jump to condition
    bnez    $s3, if_4         # (bnez) if y != 0, jump to condition
    j       y_increment

    # So at this point, we are dealing with real neighbour cells
    # is it alive? if so, count it
    # board[row][col] = *(&board[0][0] + (row * N) + col)

if_4: # if (board[i + x][j + y] == 1) nn++;
    mul $t4, $t1, $s0   # $t4 = (i + x) * N
    add $t4, $t4, $t3   # $t0 = (i + x) * N + (j + y)
    lb  $t4, board($t4) # $t4 = &board[row][col]

    bne     $t4, $t0, y_increment   # if $t4 != 1, jump to y increment
    addi    $s1, $s1, 1             # nn++; (increment nn by 1)

y_increment:
    addi $s3, $s3, 1        # y++
    j loop_y                # jump to loop_y

end_loop_y:
    addi $s2, $s2, 1        # x++
    j loop_x                # jump to loop_x

end_loop_x:

# return nn
move $v0, $s1

# clean up stack frame
lw  $s5, -28($fp)   # restore $s5 value
lw  $s4, -24($fp)   # restore $s4 value
lw  $s3, -20($fp)   # restore $s3 value
lw  $s2, -16($fp)   # restore $s2 value
lw  $s1, -12($fp)   # restore $s1 value
lw  $s0, -8($fp)    # restore $s0 value
lw  $ra, -4($fp)    # restore $ra for return
la  $sp, 4($fp) # restore $sp (remove stack frame)
lw  $fp, ($fp)  # restore $fp (remove stack frame)
# return to main
jr  $ra
