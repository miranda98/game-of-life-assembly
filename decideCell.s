decideCell:
	# set up stack frame
	sw	$fp, -4($sp)	# push $fp onto stack
	la	$fp, -4($sp)	# set up $fp for this function
	sw	$ra, -4($fp)	# save return address
	sw	$s0, -8($fp)	# $s0 = old
	sw	$s1, -12($fp)	# $s1 = nn
	addi	$sp, $sp, -16	# move $sp to top of stack

	move $s0, $a0 	# load 'old' into $s0
	move $s1, $a1	# load 'nn' into $s1

	li $t0, 1
	li $t1, 2
	li $t2, 3

if_old:
	bne $s0, $t0, else_1		# if old != 1, jump to else_1 condition

inside_if:
	bge $s1, $t1, inside_else 	# if nn >= 2, jump to else_or_nn condition
	li 	$v0, 0					# if nn < 2, return 0
	j 	exit_decideCell

inside_else:
	bne $s1, $t1, inside_else_or # if nn != 2, check other condition
	li 	$v0, 1					# if nn = 2, return 1
	j 	exit_decideCell

inside_else_or:
	bne $s1, $t2, inside_else_else # if nn != 2, nn != 3, check other condition
	li 	$v0, 1 					# if nn != 2, nn = 3, return 1
	j 	exit_decideCell 		

inside_else_else:
	li 	$v0, 0 					# return 0
	j 	exit_decideCell

else_1:
	bne $s1, $t2, else_2		# if nn != 3, jump to else_2 condition
	li 	$v0, 1					# if nn == 3, return 1
	j 	exit_decideCell

else_2:
	li 	$v0, 0 					# return 0
	j 	exit_decideCell

exit_decideCell:
	# clean up stack frame
	lw	$s1, -12($fp)	# restore $s1 value
	lw	$s0, -8($fp)	# restore $s0 value
	lw	$ra, -4($fp)	# restore $ra for return
	la	$sp, 4($fp)	# restore $sp (remove stack frame)
	lw	$fp, ($fp)	# restore $fp (remove stack frame)
	# return to main
	jr $ra

