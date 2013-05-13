############################################
# PA2.asm
# Author: Kevin Garsjo
# UO ID: 951136777
# Class: cs 314
############################################

		.data
		.align 2
BoxArray:	.space 40
TowerArray:	.space 80
NumBoxSizes:	.word 0
MaxHeights:	.word 10
MaxBoxes:	.word 20
StrTowerHeight:	.asciiz	"Tower Height:\t"
StrNumTypes:	.asciiz "Number of Box Types:\t"
StrBoxHeight:	.asciiz "Height of Box Type #C:\t"
StrSuffix:	.asciiz	":\t"
StrTowerDone:	.asciiz "Tower #"
StrNumAnswers:	.asciiz " Solution(s) found."
StrNewline:	.asciiz "\n"
StrSpace:	.asciiz " "
StrErrNumBoxes:	.asciiz "Number of Box Types cannot exceed 10. Exiting."

	.text
############################################
# Program Entry
############################################
main:	li $s0, 0	# $s0 = Number of Solutions


	la $a0, StrTowerHeight	# Get Tower Height
	jal PrintStr
	jal Input
	move $s1, $v0		# $s1 = TowerHeight
	
	la $a0, StrNumTypes	# Get number of different box heights
	jal PrintStr
	jal Input
	
	sw $v0, NumBoxSizes($s0)# Store numBoxSizes in memory
	move $t9, $v0		# $s2 = numBoxSizes
	lw $t0, MaxHeights($0)
	bgt $t9, $t0, Err1	# If (numBoxHeights > maxHeights), goto Err1
	
	li $t0, 0	# $t0 = i-counter
	li $t1, 4
	mult $t9, $t1
	mflo $t1	# $t1 = 4*numBoxHeights
	li $t2, 48	# $t2 = Ascii 0
BoxLoop:		# Get all boxes
	beq $t0, $t1, BoxLoopEnd
	
	li $t3, 20
	sb $t2, StrBoxHeight($t3)
	la $a0, StrBoxHeight
	jal PrintStr
	
	jal Input
	sw $v0, BoxArray($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	j BoxLoop
BoxLoopEnd:
	jal Newline
	
	move $a0, $s1	# Start building Towers
	li $a1, -1
	li $a2, 0
	jal BuildTower	
	
	li $v0, 1	# Print numAnswers
	move $a0, $s0
	syscall
	
	la $a0, StrNumAnswers
	jal PrintStr	# Print answer ASCII
	
	jal Newline

Exit:	li $v0, 10
	syscall
	
Err1:	la $a0, StrErrNumBoxes
	jal PrintStr
	j Exit
	
	
############################################
# BuildTower
#	Args: $a0 - Target Height of Tower
#	      $a1 - Max Box Size to use
#	      $a2 - Num boxes used so far
############################################
BuildTower:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)

	beq $a0, $zero, BTPrintCase	# If Target Height = 0, Done
	blt $a0, $zero, BTEnd		# If Target Height < 0, Invalid Case
	
	lw $t0, MaxBoxes($0)	# $t0 = Maximum Boxes (20)
	bge $a2, $t0, BTEnd	# If numBoxes so far > Max Boxes, Invalid Case
	
	li $s1, 0		# i-counter for while loop
	li $s2, 0		# byte-address offset for while loop
	lw $t0 NumBoxSizes($0)	# $t0 = NumBoxSizes (size of BoxArray)
	
BTLoop:	beq $s1, $t0, BTEnd	# If i-counter > numBoxSizes, finish loop
	lw $t1, BoxArray($s2)	# $t1 = BoxArray[$s1]
	beq $a1, -1, BTIf	# Special Case, if NMaxBoxSize == -1, tower is empty, first call
	bgt $t1, $a1, BTEndif	# If BoxSrray[$s1] <= Max Box Size to Use, do if statement

BTIf:	addi $sp, $sp -16	# Store all values
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $t0, 12($sp)
	
	mul $t3, $a2, 4
	sw $t1, TowerArray($t3)	#Store Tower Array Val

	sub $a0, $a0, $t1	# TowerHeigt = TowerHeight - NewBox
	move $a1, $t1		# MaxBoxSize = NewBox
	addi $a2, $a2, 1	# numBoxes++
	jal BuildTower		#Recursive Call
	
	lw $a0, 0($sp)		# Load back Values
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	
BTEndif:	
	addi $s1, $s1, 1	#Increment i-counter
	addi $s2, $s2, 4	#Increment word-offset
	j BTLoop
	
BTEnd:	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	
BTPrintCase:
	addi $s0, $s0, 1
	la $a0, TowerArray
	move $a1, $a2
	
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal PrintIntArray
	#jal Newline
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	
	j BTEnd


############################################
# Input
#	Args: N/A
#	Retn: $v0 - Integer from console
############################################
Input:	li $v0, 5
	syscall
	jr $ra


############################################
# PrintStr
#	Args: $a0 - String addr to print
############################################
PrintStr:
	li $v0, 4
	syscall
	jr $ra


############################################
# PrintTowerArray
#	Args: $a0 - Beginning Array Address
#	      $a1 - Array Size
############################################
PrintIntArray:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t0, 0 	# i-counter
	move $t1, $a0	# Save array address
	
	la $a0, StrTowerDone
	jal PrintStr
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	la $a0, StrSuffix
	jal PrintStr
	
PIALoop:		# Loop through Array and Print
	beq $a1, $t0, PIAExit
	
	li $v0, 1
	lw $a0, 0($t1)
	syscall
	
	li $v0, 4
	la $a0, StrSpace
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	j PIALoop
	
PIAExit:
	jal Newline
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


############################################
# Newline
#	Args: N/A
############################################
Newline:
	li $v0, 4
	la $a0, StrNewline
	syscall
	jr $ra
