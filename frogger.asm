#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
#  Syed Haider Hassan Bokhari, 1005929701
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
	displayAddress: .word 0x10008000
	grass: .word 0x00FF00
	ocean: .word 0x6060FF
	safeZone: .word 0xFFD966
	road: .word 0x404040
	frogColor: .word 0xEF00EF
	frogX: .byte 0
	frogY: .byte 0

.text
	lw $t0, displayAddress # $t0 stores the base address for display
	lw $t1, frogColor
	
	#EndZone
	li $a1, 0 #Start Value
	li $a2, 1024 #End Value
	lw $a3,  grass #Color
	jal drawLine
	#Ocean
	li $a1, 1024
	li $a2, 2048
	lw $a3, ocean
	jal drawLine
	#Safe Zone
	li $a1, 2048
	li $a2, 2560
	lw $a3, safeZone
	jal drawLine
	#Road
	li $a1, 2560
	li $a2, 3584
	lw $a3, road
	jal drawLine
	#Start Zone
	li $a1, 3584
	li $a2, 4096
	lw $a3,  grass
	jal drawLine
	
	#sw $t1, 124($t0) # paint the first (top-right) unit red.
	
	

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall

drawFrog: #Arguments: frogX, frogY
	
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 396($t0)
	jr $ra

drawLine: # Arguments: Start, End, Color
	li $t6, 0 #Current
	loopDL:
		beq $a1, $a2, end # if whole row itterated through, finish
	
		addu $t6, $a1, $t0
		sw $a3, ($t6) # paint the first row red
	
		addi $a1, $a1, 4 # add 4 to a1
		j loopDL # jump back to the top
	end:
	jr $ra

