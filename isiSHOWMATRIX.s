	.data
msg: .asciiz "Printing the board\n"
dot: .ascii "." # or .asciiz
hash: .ascii "#" # or .asciiz
eol: .asciiz "\n"

copyBackAndShow:
	# set up stack frame
	addi	$sp, $sp, -4
	sw	$fp, ($sp)	# push $fp
	la	$fp, ($sp)
	addi	$sp, $sp, -4
	sw	$ra, ($sp)	# push $ra
	addi	$sp, $sp, -4
	sw	$s0, ($sp)	# push $s0
	addi	$sp, $sp, -4
	sw	$s1, ($sp)	# push $s1
	addi	$sp, $sp, -4
	sw	$s2, ($sp)	# push $s2
	addi	$sp, $sp, -4
	sw	$s3, ($sp)	# push $s3
	addi	$sp, $sp, -4
	sw	$s4, ($sp)	# push $s3

	la 	$a0, msg 	# load the message into $a0
	li 	$v0, 4		# load system call for print (4)
	syscall			# printf("Printing the board\n")

	la 		$s0, board
	la 		$s1, newboard
	lw		$s2, N 	# $s1 = N

row_loop:
	li	$s3, 0		# $s3: int i = 0
row_condition:
	bge	$s3, $s2, end_row_loop	# if i >= N, jump to end of row loop

col_loop:
	li	$s4, 0		# $s4: int j = 0
col_condition:
	bge	$s4, $s2, end_col_loop	# if j >= N, jump to end of column loop

	# board[row][col] = *(&board[0][0] + (row * N) + col)
	mul	$t0, $s3, $s2	# $t0 = row * N
	add	$t0, $t0, $s4	# $t0 = (row * N) + col
	li	$t1, 4			# $t1 = 4 (sizeof(word))
	mul	$t0, $t0, $t1	# $t0 = [(row * N) + col] * sizeof(word)
	add	$t1, $s0, $t0	# $t1 = &board[row][col]
	add $t2, $s1, $t0	# $t2 = &newboard[row][col]

	move $t2, $t1		# board[i][j] = newboard[i][j];

# then print out the current board
	bnez	$t1, else_cond	# if board[i][j] != 0, jump to else_cond

	# print '.'
	move	$a0, dot
	li		$v0, 4
	syscall

	else_cond:
	# print '#'
	move	$a0, hash
	li		$v0, 4
	syscall

increment_col:
	addi	$s3, $s3, 1	# col++
	j	col_condition
	#nop	#[branch delay]
end_col_loop:

	li	$a0, eol
	li	$v0, 4
	syscall			# putchar('\n')

increment_row:
	addi	$s2, $s2, 1	# row++
	j	row_condition
	#nop	#[branch delay]
end_row_loop:

showM__epi:
	# tear down stack frame
	lw

	lw	$s3, ($sp)	# pop $s3
	addi	$sp, $sp, 4
	lw	$s2, ($sp)	# pop $s2
	addi	$sp, $sp, 4
	lw	$s1, ($sp)	# pop $s1
	addi	$sp, $sp, 4
	lw	$s0, ($sp)	# pop $s0
	addi	$sp, $sp, 4
	lw	$ra, ($sp)	# pop $ra
	addi	$sp, $sp, 4
	lw	$fp, ($sp)	# pop $fp
	addi	$sp, $sp, 4
	jr	$ra