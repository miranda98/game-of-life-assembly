# Data segment
	.data
msg_printingBoard:	.asciiz "Printing the board\n"
dot:	.asciiz "."
hash:	.asciiz "#"
eol:	.asciiz "\n"

# void copyBackAndShow (void)
# {
# 	for (int i = 0; i < N; i++) {
# 		for (int j = 0; j < N; j++) {
# 			// load all the values you found from newboard
# 			// into the current board
# 			board[i][j] = newboard[i][j];

# 			// then print out the current board
# 			if (board[i][j] == 0)
# 				putchar ('.');
# 			else
# 				putchar ('#');
# 		}
# 		putchar ('\n');
# 	}
# }

# Code segment
	.text
	.globl main	# another file can refer to main

# main() function
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

	la 	$a0, msg_printingBoard 	# load the message into $a0
	li 	$v0, 4		# load system call for print (4)
	syscall			# printf("Printing the board\n")

	lw		$s0, N 	# $s0 = N

row_loop:
	li	$s1, 0		# $s1: int i = 0
row_condition:
	bge	$s1, $s0, end_row_loop	# if i >= N, jump to end of row loop

col_loop:
	li	$s2, 0		# $s2: int j = 0
col_condition:
	bge	$s2, $s0, end_col_loop	# if j >= N, jump to end of column loop

	# board[row][col] = *(&board[0][0] + (row * N) + col)
	mul	$t0, $s1, $s0	# $t0 = row * N
	add	$t0, $t0, $s2	# $t0 = (row * N) + col
	lb	$t1, board($t0)	# load board[row][col] into $t1
						# add $t1, $s0, $t0	# $t1 = &board[row][col]
	la 	$s3, newBoard
	add $s3, $s3, $t0
	move $s3, $t1
	#move newBoard($t0), $t1		# board[i][j] = newboard[i][j]; ?????????????????????????????????????

# then print out the current board
	bnez	$t1, else_cond	# if board[i][j] != 0, jump to else_cond

	# print '.'
	la	$a0, dot
	li	$v0, 4
	syscall
	j 	increment_col

	else_cond:
	li	$t3, 1
	bne $t1, $t3, increment_col
	# print '#'
	la	$a0, hash
	li	$v0, 4
	syscall

increment_col:
	addi	$s2, $s2, 1	# col++
	j 		col_condition

end_col_loop:

	la	$a0, eol
	li	$v0, 4
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