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
.text
	lw $t0, displayAddress # $t0 stores the base address for display
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0x00ff00 # $t2 stores the green colour code
	li $t3, 0x0000ff # $t3 stores the blue colour code
	
	#EndZone
	li $a1, 0 #Start Value
	li $a2, 1024 #End Value
	li $a3, 0x00FF00  #Color
	jal drawLine
	#Ocean
	li $a1, 1024
	li $a2, 2048
	li $a3, 0x6060FF
	jal drawLine
	#Safe Zone
	li $a1, 2048
	li $a2, 2560
	li $a3, 0xFFD966
	jal drawLine
	#Road
	li $a1, 2560
	li $a2, 3584
	li $a3, 0x404040
	jal drawLine
	#Start Zone
	li $a1, 3584
	li $a2, 4096
	li $a3, 0x00FF00
	jal drawLine
	
	#sw color, offset(origin)
	#sw $t1, 0($t0) # paint the first (top-left) unit red.
	#sw $t1, 124($t0) # paint the first (top-right) unit red.
	#sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
	#sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall

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

