# int main (void)
# {
	.data
msg_iter: .asciiz "# Iterations: "
msg_afterIter_1: .asciiz "=== After iteration "
msg_afterIter_2: .asciiz " ==="
eol: .asciiz "\n"

n: .asciiz "n: "
i: .asciiz "i: "
jay: .asciiz "j: "


msg_printingBoard:	.asciiz "Printing the board\n"
dot:	.asciiz "."
hash:	.asciiz "#"

N:	.word 10  # gives board dimensions

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

newBoard: .space 100

	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow	
	.text

main:
	# Set up stack frame.
	sw	$fp, -4($sp)	# push $fp onto stack
	la	$fp, -4($sp)	# set up $fp for this function
	sw	$ra, -4($fp)	# save return address
	sw	$s0, -8($fp)	# $s0 = n
	sw	$s1, -12($fp)	# $s1 = i
	sw	$s2, -16($fp)	# $s2 = j
	sw	$s3, -20($fp)	# $s3 = N
	sw	$s4, -24($fp)	# $s4 = maxiters
	sw 	$s5, -28($fp)	# $s5 = nn
	sw  $s6, -32($fp)   # for board matrix offset
	sw 	$s7, -36($fp)	# for newBoard matrix offset
	addi	$sp, $sp, -40	# move $sp to top of stack

	lw		$s3, N 			# Load N value into $s3

# printf ("# Iterations: ");
	la 		$a0, msg_iter
	li 		$v0, 4
	syscall

# int maxiters;
# scanf ("%d", &maxiters);
	li 		$v0, 5
	syscall
	move 	$s4, $v0

	li 		$s0, 1		# int n = 1

for_n:						# for (int n = 1; n <= maxiters; n++)
	bgt 	$s0, $s4, end_for_n	# if n > maxiters, go to end_for_n
	li 		$s1, 0				# int i = 0

for_i:						# for (int i = 0; i < N; i++)
	bge 	$s1, $s3, end_for_i	# if i >= N, go to end_for_i
	li 		$s2, 0				# int j = 0

for_j:						# for (int j = 0; j < N; j++)
	bge 	$s2, $s3, end_for_j	# if j >= N, go to end_for_j

# int nn = neighbours (i, j);
	move	$a0, $s1 	# load i into $a0
	move	$a1, $s2	# load j into $a1
	jal 	neighbours	# neighbours(i, j)
	move 	$s5, $v0	# load return value into $s5 (nn) --- $s5 = nn

# calculate offset for board[i][j] ---- board[i][j] = *(&board[0][0] + (i * N) + j)
	mul		$s6, $s1, $s3	# $t0 = i * N
	add		$s6, $s6, $s2	# $t0 = (i * N) + j
	lb		$t1, board($s6)	# load board[i][j] into $t1

	move 	$a0, $t1 	# load board[i][j] into $a0
	move 	$a1, $s5	# load nn into $a1
	jal 	decideCell
	la 		$s7, newBoard
	add 	$s7, $s7, $s6
	sb 		$v0, ($s7) 	# load return value into newBoard[i][j]

	addi 	$s2, $s2, 1	# j++
	j 		for_j 			# jump to start of loop j

end_for_j:				# if j >= N
	addi 	$s1, $s1, 1 	# i++
	j 		for_i 			# jump to start of loop i

end_for_i: 				# if i >= N

	la 		$a0, msg_afterIter_1 # printf("=== After iteration ")
	li 		$v0, 4
	syscall

	move 	$a0, $s0 	# printf("n")
	li 		$v0, 1
	syscall

	la 		$a0, msg_afterIter_2 # printf(" ===")
	li 		$v0, 4
	syscall

	la 		$a0, eol 		# printf("\n")
	li 		$v0, 4
	syscall

# Load the newboard into the current board ---- copyBackAndShow ();
	jal 	copyBackAndShow

	addi 	$s0, $s0, 1 	# n++;
	j 		for_n

end_for_n:

	# clean up stack frame
	lw 	$s7, -36($fp)
	lw  $s6, -32($fp)   # restore $s6 value
	lw 	$s5, -28($fp)	# restore $s5 value
	lw	$s4, -24($fp)	# restore $s4 value
	lw	$s3, -20($fp)	# restore $s3 value
	lw	$s2, -16($fp)	# restore $s2 value
	lw	$s1, -12($fp)	# restore $s1 value
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)		# restore $sp (remove stack frame)
	lw	$fp, ($fp)		# restore $fp (remove stack frame)
	# return 0;
	li 	$v0, 0
	jr 	$ra


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
    bgt 	$s2, $t0, end_loop_x    # if x > 1, jump to end_loop_x
    li  	$s3, -1             	# int y = -1;

loop_y:
    bgt 	$s3, $t0, end_loop_y    # if y > 1, jump to end_loop_y

if_1:							# if (i + x < 0 || i + x > N - 1) continue;
    add     $t1, $s4, $s2       # $t1 = i + x
    bgez    $t1, if_1_1         # if $t1 >= 0, jump to next condition
    j       y_increment			# if $t1 < 0, go back to start of the loop

if_1_1:
    sub     $t2, $s0, 1         # $t2 = N - 1
    bge     $t2, $t1, if_2      # if $t2 >= $t1, (N-1 >= i+x) jump to next condition
    j       y_increment			# if $t1 > $t2, go back to start of the loop

if_2: 							# if (j + y < 0 || j + y > N - 1) continue;
    add     $t3, $s5, $s3       # $t3 = j + y
    bgez    $t3, if_2_1         # if $t3 >= 0, jump to next condition
    j       y_increment			# if $t3 < 0, go back to start of the loop

if_2_1:                                # $t2 = N-1 ( as above )
    bge     $t2, $t3, if_3      # if $t2 >= $t3, jump to next condition
    j       y_increment			# if $t3 > $t2, go back to start of the loop

if_3:						 	# if (x == 0 && y == 0) continue;
    bnez    $s2, if_4         	# if x != 0, jump to next condition
    bnez    $s3, if_4         	# if y != 0, jump to next condition
    j       y_increment 		# if y = 0, go back to start of the loop

if_4: 					# if (board[i + x][j + y] == 1) nn++;
    mul 	$t4, $t1, $s0   # $t4 = (i + x) * N
    add 	$t4, $t4, $t3   # $t0 = (i + x) * N + (j + y)
    lb  	$t4, board($t4) # $t4 = &board[row][col]

    bne     $t4, $t0, y_increment   # if $t4 != 1, jump to y increment
    addi    $s1, $s1, 1             # nn++; (increment nn by 1)

y_increment:
    addi 	$s3, $s3, 1        # y++
    j 		loop_y                # jump to loop_y

end_loop_y:
    addi	$s2, $s2, 1        # x++
    j 		loop_x                # jump to loop_x

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

decideCell:
	# set up stack frame
	sw	$fp, -4($sp)	# push $fp onto stack
	la	$fp, -4($sp)	# set up $fp for this function
	sw	$ra, -4($fp)	# save return address
	sw	$s0, -8($fp)	# $s0 = old
	sw	$s1, -12($fp)	# $s1 = nn
	addi	$sp, $sp, -16	# move $sp to top of stack

	move 	$s0, $a0 	# load 'old' into $s0
	move	$s1, $a1	# load 'nn' into $s1

	li 		$t0, 1
	li 		$t1, 2
	li 		$t2, 3

if_old:
	bne 	$s0, $t0, else_1		# if old != 1, jump to else_1 condition

inside_if:
	bge 	$s1, $t1, inside_else 	# if nn >= 2, jump to inside_else condition
	li 		$v0, 0					# if nn < 2, return 0
	j 		exit_decideCell

inside_else:
	bne 	$s1, $t1, inside_else_or # if nn != 2, check other condition
	li 		$v0, 1					# if nn = 2, return 1
	j 		exit_decideCell

inside_else_or:
	bne 	$s1, $t2, inside_else_else # if nn != 2, nn != 3, check other condition
	li 		$v0, 1 					# if nn != 2, nn = 3, return 1
	j 		exit_decideCell 		

inside_else_else:
	li 		$v0, 0 					# return 0
	j 		exit_decideCell

else_1:
	bne 	$s1, $t2, else_2		# if nn != 3, jump to else_2 condition
	li 		$v0, 1					# if nn == 3, return 1
	j 		exit_decideCell

else_2:
	li 		$v0, 0 					# return 0
	j 		exit_decideCell

exit_decideCell:
	# clean up stack frame
	lw	$s1, -12($fp)	# restore $s1 value
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	# restore $sp (remove stack frame)
	lw	$fp, ($fp)	# restore $fp (remove stack frame)
	# return to main
	jr 	$ra

copyBackAndShow:
	# Set up stack frame.
	sw	$fp, -4($sp)	# push $fp onto stack
	la	$fp, -4($sp)	# set up $fp for this function
	sw	$ra, -4($fp)	# save return address
	sw	$s0, -8($fp) 	# $s0 = N
	sw	$s1, -12($fp) 	# $s1 = i
	sw	$s2, -16($fp) 	# $s2 = j
	sw 	$s3, -20($fp) 	# $s3 is the address for newBoard
	addi	$sp, $sp, -24	# move $sp to top of stack

	la 		$a0, msg_printingBoard 	# load the message into $a0
	li 		$v0, 4		# load system call for print (4)
	syscall			# printf("Printing the board\n")

	lw		$s0, N 	# $s0 = N

row_loop:
	li		$s1, 0		# $s1: int i = 0
row_condition:
	bge		$s1, $s0, end_row_loop	# if i >= N, jump to end of row loop

col_loop:
	li		$s2, 0		# $s2: int j = 0
col_condition:
	bge		$s2, $s0, end_col_loop	# if j >= N, jump to end of column loop

	# board[row][col] = *(&board[0][0] + (row * N) + col)
	mul		$t0, $s1, $s0	# $t0 = row * N
	add		$t0, $t0, $s2	# $t0 = (row * N) + col
	lb		$t1, newBoard($t0)	# load board[row][col] into $t1
						# add $t1, $s0, $t0	# $t1 = &board[row][col]
	la 		$s3, board
	add 	$s3, $s3, $t0
	sb  	$t1, ($s3)
	#move newBoard($t0), $t1		# board[i][j] = newboard[i][j]; ?????????????????????????????????????

# then print out the current board
	bnez	$t1, else_cond	# if board[i][j] != 0, jump to else_cond

	# print '.'
	la		$a0, dot
	li		$v0, 4
	syscall
	j 		increment_col

	else_cond:
	li		$t3, 1
	bne 	$t1, $t3, increment_col
	# print '#'
	la		$a0, hash
	li		$v0, 4
	syscall

increment_col:
	addi	$s2, $s2, 1	# col++
	j 		col_condition

end_col_loop:

	la		$a0, eol
	li		$v0, 4
	syscall			# putchar('\n')

increment_row:
	addi	$s1, $s1, 1	# row++
	j		row_condition

end_row_loop:
	# clean up stack frame
	lw 	$s3, -20($fp)	# restore $s3 value
	lw	$s2, -16($fp)	# restore $s2 value
	lw	$s1, -12($fp)	# restore $s1 value
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	# restore $sp (remove stack frame)
	lw	$fp, ($fp)	# restore $fp (remove stack frame)

	li	$v0, 0	# return 0
	jr	$ra		# return to main