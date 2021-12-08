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
# - Milestone 1/2
#
# Which approved additional features have been implemented?
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
	displayAddress: .word 0x10008000
	pixelSpace: .space 0x20000
	carRow1: .word 0,4
	carRow2: .word 1,5
	carRow3: .word 0,1
	logRow1: .word 0,4
	logRow2: .word 1,5
	logRow3: .word 0,5
	score: .byte 0
	frogX: .byte 16
	frogY: .byte 0
	lives: .byte 3
	str2: .asciiz "Lives Remaining: "
	scoreStr: .asciiz "Your Score is: "
	newLine: .asciiz "\n"
	grass: .word 0x00FF00
	ocean: .word 0x6060FF
	safeZone: .word 0xFFD966
	road: .word 0x404040
	WinColor: .word 0x731F67
	black: .word 0x000000
	red: .word 0xFF1010
	log: .word 0x732F00
	log2: .word 0x732F01
	frogColor: .word 0x4CA620

.text
li $s5, 0
li $s6, 0
main:
	lw $t0, displayAddress # $t0 stores the base address for display
	
	#check for keypress
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
	

#EndZone
	li $a1, 0 #Start Value
	li $a2, 512 #End Value
	lw $a3,  WinColor #Color
	jal drawLine
	#Ocean
	li $a1, 512
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
	li $a2, 4096
	lw $a3, road
	jal drawLine
	#Start Zone
	li $a1, 4096
	li $a2, 8192
	lw $a3,  grass
	jal drawLine
	
	la $a0, logRow1
	li $a1, 1 # y cord
	lw $a2, log
	li $s1, 512 #Starting row
	jal drawRow
	la $a0, logRow2
	li $a1, 2 # y cord
	lw $a2, log2
	li $s1, 1024 #Starting row
	jal drawRow
	la $a0, logRow3
	li $a1, 3 # y cord
	lw $a2, log
	li $s1, 2560 #Starting row
	jal drawRow
	jal drawFrog
	la $a0, carRow1
	li $a1, 5 # y cord
	lw $a2, red
	li $s1, 3072 #Starting row
	jal drawRow
	la $a0, carRow2
	li $a1, 6 # y cord
	lw $a2, red
	li $s1, 3072 #Starting row
	jal drawRow
	la $a0, carRow3
	li $a1, 7 # y cord
	lw $a2, red
	li $s1, 3584 #Starting row
	jal drawRow

#Move Arrays
	bne $s5, 30, SkipMoveArray #if not 30, skip
	li $s5, 0
	la $a0, carRow1
	jal MoveRow
	la $a0, logRow2
	jal MoveRow

	lw $t1, 4($s4) #color of frog's top left into t1
	la $a0, frogX
	lb $t3, ($a0) #get value
	lw $t2, log2
	bne $t1, $t2, SkipMoveArray
	addi $a2, $t3, 4 #sub 4 to y value
	sb $a2, 0($a0) #save new value

	SkipMoveArray:
	bne $s6, 50, SkipMoveArray2 #if not 50, skip
	li $s6, 0
	la $a0, carRow2
	jal MoveRow

	la $a0, logRow1
	jal MoveRowB

	la $a0, logRow3
	jal MoveRowB

	la $a0, carRow3
	jal MoveRowB

	lw $t1, 4($s4) #color of frog's top left into t1
	la $a0, frogX
	lb $t3, ($a0) #get value
	lw $t2, log
	bne $t1, $t2, SkipMoveArray2
	subi $a2, $t3, 4 #sub 4 to y value
	sb $a2, 0($a0) #save new value


	SkipMoveArray2:

#collision detection - cars
	lw $t1, 4($s4) #color of frog's top left into t1
	lw $t2, red
	beq $t1, $t2, HitCar
	lw $t2, ocean
	beq $t1, $t2, HitWater
	j notHit
HitCar:
	#Car Sound
	li $v0, 31
	li $a1, 150 # duration
	li $a0, 70 #pitch
	li $a2, 70 #instrument
	li $a3, 60 #volume
	syscall
	li $v0, 31
	li $a1, 150 # duration
	li $a0, 50 #pitch
	li $a2, 70 #instrument
	li $a3, 60 #volume
	syscall
	j FrogHit

HitWater:
	li $v0, 31
	li $a1, 250 # duration
	li $a0, 50 #pitch
	li $a2, 64 #instrument
	li $a3, 30 #volume
	syscall
	
FrogHit:
	lb $t3, lives
	subi $t3, $t3, 1
	sb $t3, lives

	lb $t4, frogX
	addi $t4, $zero, 16
	sb $t4, frogX

	
	la $a0, str2
    li $v0, 4 
    syscall
	lb $a0, lives #integer to be printed
	li $v0, 1 #system call code 1: print_int
	syscall
	la $a0, newLine
    li $v0, 4 
	syscall

	lb $t5, frogY
	addi $t5, $zero, 0
	sb $t5, frogY
	beq $t3, 0, LoseGame

notHit:

	#Win Detection
	lw $t1, 4($s4) #color of frog's top left into t1
	lw $t2, WinColor
	beq $t1, $t2, WinJ

	addi $s6, $s6, 1 #increment movement counter
	addi $s5, $s5, 1 #increment movement counter

	li $v0, 32
	li $a0, 16
	syscall
	j main
WinJ:
#WinSound
		li $v0, 31
		li $a1, 1300 # duration
		li $a0, 70 #pitch
		li $a2, 2 #instrument
		li $a3, 30 #volume
		syscall

		la $t5, score
		lb $t4, ($t5) #get score
  		subi $t6, $t4, 500 #add 500 for winning
  		sb $t6, 0($t5) #save new value
		la $a0, scoreStr
		li $v0, 4 
		syscall
		lb $a0, score #integer to be printed
		li $v0, 1 #system call code 1: print_int
		syscall
		la $a0, newLine
		li $v0, 4 
		syscall
		j Exit
LoseGame:
		#LoseSound
		li $v0, 31
		li $a1, 700 # duration
		li $a0, 30 #pitch
		li $a2, 35 #instrument
		li $a3, 50 #volume
		syscall
		li $v0, 31
		li $a1, 500 # duration
		li $a0, 35 #pitch
		li $a2, 35 #instrument
		li $a3, 50 #volume
		syscall
		li $v0, 31
		li $a1, 600 # duration
		li $a0, 45 #pitch
		li $a2, 35 #instrument
		li $a3, 50 #volume
		syscall
Exit:
	li $v0, 10 # terminate the program gracefully
syscall

drawFrog:
	lw $t1, frogColor
	lb $a1, frogX #y = (512)(9-y)
	lb $a2, frogY 
	li $t6, 0 #Current
	li $t5, 36
	sub $t5, $t5, $a2
	li $t6, 128
	mult $t5, $t6
	mflo $t3
	li $t5, 4
	mult $a1, $t5
	mflo $t5
	add $t3, $t3, $t5
	addu $t6, $t3, $t0
	addu $s4, $t3, $t0 #frog's top left pixel stored in $s4

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
	
	
drawRow: # a0: array, a1: y axis, a2: color
	li $t6, 0
	LoopDR:
		beq $t6, 8, endDR
		li $t3, 0
		add $t3, $t6, $a0 # t3 = A[i]
		lw $t4, ($t3) # t4 = value of A[i]
		li $t8, 0
		add $t8, $t8, $t4 # x coordinate
		
		#Drawing:
		li $t7, 0
		sll $t1, $t8, 4 #x coordinate
		sll $t5, $a1, 2, #y coord
		sll $t5, $t5, 7
		add $t7, $t1, $t5 # top left of car
		add $s7, $s1, $t0 # top left of row
		add $t7, $t7, $t0
		
		sw $a2, 0($t7) #1
		sw $a2, 128($t7) #1
		sw $a2, 256($t7) #1
		sw $a2, 384($t7) #1

		li $s2, 0
		Loop7Draw: beq $s2, 7, Loop7End
			addi $t7, $t7, 4
			sub $s3, $t7, $s7
			ble $s3, 127, Skip1 # if current pixel goes out of current line
				add $t7, $s7, $zero #make current pixel corner pixel
			Skip1:
			sw $a2, 0($t7) #1
			sw $a2, 128($t7) #1
			sw $a2, 256($t7) #1
			sw $a2, 384($t7) #1
			addi $s2, $s2, 1
			j Loop7Draw
		Loop7End:

		add $t6, $t6, 4
		j LoopDR
	endDR:
		jr $ra
	
keyboard_input: 
   	la $a0, frogX
   	la $a1, frogY
	la $t5, score
   	
	lw $t2, 0xffff0004
	beq $t2, 0x77, respond_to_W
	beq $t2, 0x61, respond_to_A
	beq $t2, 0x73, respond_to_S
	beq $t2, 0x64, respond_to_D
	beq $t2, 0x1b, Exit

	j key_exit
	
	respond_to_W:
		lb $t3, ($a1) #get value
  		addi $a2, $t3, 4 #add 4 to y value
  		sb $a2, 0($a1) #save new value

		li $v0, 31
		li $a1, 150 # duration
		li $a0, 72 #pitch
		li $a2, 85 #instrument
		li $a3, 30 #volume
		syscall

		lb $t4, ($t5) #get score
  		addiu $t6, $t4, 100 #add 4 to y value
  		sb $t6, 0($t5) #save new value
		la $a0, scoreStr
		li $v0, 4 
		syscall
		lb $a0, score #integer to be printed
		li $v0, 1 #system call code 1: print_int
		syscall
		la $a0, newLine
		li $v0, 4 
		syscall

		j key_exit
		
	respond_to_A:
		lb $t3, ($a0) #get value
  		subi $a2, $t3, 4 #add 4 to y value
  		sb $a2, 0($a0) #save new value

		li $v0, 31
		li $a1, 150 # duration
		li $a0, 72 #pitch
		li $a2, 85 #instrument
		li $a3, 30 #volume
		syscall
		j key_exit
		
	respond_to_S:
		lb $t3, ($a1) #get value
  		subi $a2, $t3, 4 #add 4 to y value
  		sb $a2, 0($a1) #save new value

		li $v0, 31
		li $a1, 150 # duration
		li $a0, 72 #pitch
		li $a2, 85 #instrument
		li $a3, 30 #volume
		syscall

		lb $t4, ($t5) #get score
  		subi $t6, $t4, 100 #add 4 to y value
  		sb $t6, 0($t5) #save new value
		la $a0, scoreStr
		li $v0, 4 
		syscall
		lb $a0, score #integer to be printed
		li $v0, 1 #system call code 1: print_int
		syscall
		la $a0, newLine
		li $v0, 4 
		syscall

		j key_exit
		
	respond_to_D:
		lb $t3, ($a0) #get value
  		addi $a2, $t3, 4 #add 4 to y value
  		sb $a2, 0($a0) #save new value

		li $v0, 31
		li $a1, 150 # duration
		li $a0, 72 #pitch
		li $a2, 85 #instrument
		li $a3, 30 #volume
		syscall

		j key_exit
	
	key_exit:
		jr $ra

MoveRow: #a0: length of array , a1: array [1] address
	li $t3, 0
	LoopMR:
		lw $s0, 0($a0) 
		addi $s0, $s0, 1
		li $t2, 8
		bge $s0, $t2, overflow 
		blt $s0, $t2, bounded 
	overflow:
		li $s0, 0
	bounded:
		sw $s0, 0($a0) # save value
		addi $a0, $a0, 4
		addi $t3, $t3, 1
		beq $t3, 1, LoopMR
		jr $ra

MoveRowB: #a0: length of array , a1: array [1] address
	li $t3, 0
	LoopMRB:
		lw $s0, 0($a0) 
		addi $s0, $s0, -1 
		li $t2, 0
		bge $s0, $t2, boundedB
		blt $s0, $t2, overflowB 
	overflowB:
		li $s0, 7
	boundedB:
		sw $s0, 0($a0) # save value
		addi $a0, $a0, 4
		addi $t3, $t3, 1
		beq $t3, 1, LoopMRB
		jr $ra
