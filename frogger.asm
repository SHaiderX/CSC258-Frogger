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
	vehicleSpace: .space 512
	grass: .word 0x00FF00
	ocean: .word 0x6060FF
	safeZone: .word 0xFFD966
	road: .word 0x404040
	black: .word 0x000000
	red: .word 0xFF1010
	frogColor: .word 0x4CA620
	frogX: .byte 16
	frogY: .byte 0

.text
main:
	lw $t0, displayAddress # $t0 stores the base address for display

	
	
	#Adds pixels to array
	la $a1, vehicleSpace      #$t8 holds address of vehicleSpace array
	lw $a2,  red #Color
	jal storeArray
	
	#Paint Array
	li $a1, 2560
	li $a2, 3072
	la $a3, vehicleSpace
	jal drawRow

	
	#UI
	li $a1, 0 #Start Value
	li $a2, 512 #End Value
	lw $a3,  black #Color
	jal drawLine
	#EndZone
	li $a1, 512 #Start Value
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
	#li $a1, 2560
	#li $a2, 3584
	#lw $a3, road
	#jal drawLine
	#Start Zone
	li $a1, 3584
	li $a2, 4096
	lw $a3,  grass
	jal drawLine

	jal drawFrog
	
#li $v0, 32
#li $a0, 16
#syscall
#j main

Exit:
	li $v0, 10 # terminate the program gracefully
syscall

drawFrog: #Arguments: frogX, frogY
	lw $t1, frogColor

	lb $a1, frogX
	lb $a2, frogY 
	li $t6, 0 #Current
	li $t5, 28
	sub $t5, $t5, $a2
	li $t6, 128
	mult $t5, $t6
	mflo $t3
	li $t5, 4
	mult $a1, $t5
	mflo $t5
	add $t3, $t3, $t5
	
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 12
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 116
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 4
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 4
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 4
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 120
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 4
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 120
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 4
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 4
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	addi $t3, $t3, 4
	addu $t6, $t3, $t0
	sw $t1, ($t6)
	jr $ra



drawLine: # Arguments: Start, End, Color
	li $t6, 0 #Current
	loopDL:
		beq $a1, $a2, end # if whole row itterated through, finish
	
		add $t6, $a1, $t0
		sw $a3, ($t6)
	
		addi $a1, $a1, 4 # add 4 to a1
		j loopDL # jump back to the top
	end:
		jr $ra

storeArray:
	li $t1, 512
    	add $t2, $zero, $zero    #$t2 holds i=0
	li $t6, 0 #Current
	loopSA:
		bge $t2, $t1, endSA # if whole row itterated through, finish
		li $t7, 0
		li $t5, 8
		inLoopSA:
			beq $t7, $t5, inendSA #when 8 loops
			add $t6, $a1, $t2  #$t6 = A[i]
			sw $a2, 0($t6) #A[i] = color
			addi $t2, $t2, 4 # add 4 to t2
			addi $t7, $t7, 1
			j inLoopSA
		inendSA:
		addi $t2, $t2, 32 # skip 8 empty pixels
		j loopSA # jump back to the top
	endSA:
		jr $ra

drawRow: # Arguments: Start, End, Color
	li $t6, 0 #Current
	li $t7, 0 #index i for array
	loopDR:
		beq $a1, $a2, endDR # if whole row itterated through, finish
		add $t3, $a3, $t7  #$a3 = A[i]
		add $t6, $a1, $t0  #$t6 = current pixel
		
		sw $t3, 0($t6)
	
		addi $t7, $t7, 4
		addi $a1, $a1, 4 # add 4 to a1
		j loopDR # jump back to the top
	endDR:
		jr $ra
	#sw $t1, 124($t0) # paint the first (top-right) unit red.