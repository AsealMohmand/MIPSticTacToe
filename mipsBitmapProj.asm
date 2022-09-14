#Aseal Mohmand Bitmap Project Tic-tac-toe
#Prof Mazidi Computer acrchitecture CS 2340.002
#512x512, $gp, 4x4
#move with WASD
#press E to place shape 
#space to exit
#keep green dot inside grid, once a player has won reset program
		
						.data
#for colors, delay, and memory
.eqv	RED	0x00FF0000
.eqv	GREEN	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE	0x00FFFFFF
.eqv	YELLOW 0x00FFFF00
.eqv	CYAN	0x0000FFFF
.eqv	MAGENTA	0x00FF00FF
.eqv	 WIDTH 128
.eqv 	HEIGHT 128
.eqv	MEM	0x10008000
.eqv	DELAY	1		
		
		
		.text
#$a0 = x, $a1 = y, #a2 = color, $t8 shape counter
#loads immediates for program use and data table
main:
	li $s0, 9
	li $s1, 8
	li $s2, 7
	li $s3, 6
	li $s4, 5
	li $s6, 12
	li $s7, 17
	li $t6, 106
	li $t0, 0
	li $t9, 512
	jal drawBoard
loop:
	#li $a2, 7	
		#loop draw
	jal drawPixel #loop draw
inside:	
	# check for input
	lw $t0, 0xffff0000  
    	beq $t0, 0, loop   # no input keep displayi
	
	# process input
	lw 	$t4, 0xffff0004
	beq	$t4, 32, exit	# space
	beq	$t4, 119, up 	# w
	beq	$t4, 115, down 	#  s
	beq $t4, 97, left  	# a
	beq	$t4, 100, right	#  d
	beq	$t4, 101, placeShape	#  e
	
	j	loop
	
	# process valid input
	
up:	
	li $a2, 0
	jal drawPixel
	li $a2, GREEN
	subi $a1, $a1, 42
	jal drawPixel
	j loop

down:	
	li $a2, 0
	jal drawPixel
	li $a2, GREEN
	addi $a1, $a1, 42
	jal drawPixel
	j loop
	
left:	
	li $a2, 0
	jal drawPixel
	li $a2, GREEN
	subi $a0, $a0, 42
	jal drawPixel
	j loop
	
right:
	li $a2, 0
	jal drawPixel
	li $a2, GREEN
	addi $a0, $a0, 42
	jal drawPixel
	j loop
placeShape:
	#if $t8 even draw X if odd draw circle
	#$t7 holds andi value, #t8 is counter
	li $a2, 0
	jal drawPixel
	li $a2, GREEN
	
	and $t7, $t8, 0x0001
	jal colorPicker
	beq $t7, 0, drawX
	beq $t7, 1, drawO
	
drawBoard:	#initiates drawing of board
#$t0 = i
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	li $a2, WHITE
	li $a0, 171
	li $a1, 0
drawLeftVert:	#draws left veritcal
	bge $t0, $t9, nextVert
	jal drawPixel
	addi $t0, $t0, 1
	addi $a1, $a1, 1
	j drawLeftVert		
nextVert:	#fixes registers
	li $t0, 0
	li $a0, 342
	li $a1, 0	
drawRightVert:	#draws right vertical
	bge $t0, $t9, drawFirstHorif
	jal drawPixel
	addi $t0, $t0, 1
	addi $a1, $a1, 1	
	j drawRightVert
drawFirstHorif:	#fixes regsiters
	li $t0, 0
	li $a0, 0
	li $a1, 43
	li $t9, 128
drawTopHori:	#draws top horizontal
	bge $t0, $t9, nextHori
	jal drawPixel
	addi $t0, $t0, 1
	addi $a0, $a0, 1
	j drawTopHori
nextHori:	#fixes registers
	li $t0, 0
	li $a0, 0
	li $a1, 86
	li $t9, 128
drawBotHori: #draws bot horizontal
	bge $t0, $t9, middlePlacementDone
	jal drawPixel
	addi $t0, $t0, 1
	addi $a0, $a0, 1
	j drawBotHori	
#after game board is done set pixel to middle for movement
middlePlacementDone:
	li $a0, 64
	li $a1, 64 
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra		
exit:
	li $v0, 10
	syscall
	
	
drawPixel:
#t4 =  save address for pixel to be drawn
	addi $sp, $sp, -8
	
	sw $t4, 4($sp)
	sw $ra, ($sp)
	
	mul $t4, $a1, WIDTH
	add $t4, $t4, $a0
	mul $t4, $t4, 4
	add $t4, $t4, MEM
	sw $a2, ($t4)
	
	#delay
	move $t5, $a0 #saves x value to be restored
	li $a0, DELAY
	li $v0, 32
	syscall
	move $a0, $t5
	
	lw $ra, ($sp)
	lw $t4,4 ($sp)
	
	addi $sp, $sp, 8
	jr $ra
	
##draw X commands			
drawX:
	jal saveSpot	 #saves where the shape was drawn
	addi $a0, $a0, -10
	addi $a1,$a1, -10
	li $t0, 0
 drawLeftBar:
 	bge $t0, 20, drawRightBarFix
	jal drawPixel
	addi $t0, $t0, 1
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j drawLeftBar	
drawRightBarFix: 	
 	addi $a1,$a1, -20
 	li $t0, 0
 drawRightBar:
 	bge $t0, 20, xDone
	jal drawPixel
	addi $t0, $t0, 1
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	j drawRightBar
 xDone:	
 #checks if win and goes back to game loop
 	jal checkWin
 	
 	li $a0, 64
	li $a1, 64
	li $a2, GREEN 
	addi $t8, $t8, 1
	j loop
	
#draw circle commands, had to be hard coded	
drawO:	
	jal saveSpot
	addi $a0,$a0, -8
	addi $a1, $a1, 3
	li $t0, 0
drawOL:
#draw circle left portion	
	bge $t0, 6, oArch
	jal drawPixel
	addi $a1, $a1, -1
	addi $t0, $t0, 1
	j drawOL
oArch:	
#draw circle left arch
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal drawPixel
	li $t0, 0
oTop:
#draw circle top line
	bge $t0, 7, orArch
	jal drawPixel
	addi $a0, $a0, 1
	addi $t0, $t0, 1
	j oTop	
orArch:
#draw circle top right arch
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal drawPixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal drawPixel
	li $t0, 0
drawOR:
#draw circle right side
	bge $t0, 7, oArchBotR
	jal drawPixel
	addi $a1, $a1, 1
	addi $t0, $t0, 1
	j drawOR
oArchBotR:
#draw circle bot right arch
	jal drawPixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal drawPixel
	addi $a0, $a0,-1
	addi $a1, $a1,1
	jal drawPixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal drawPixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal drawPixel
	li $t0, 0
oBot:
#draw circle bottom line
	bge $t0, 7, oLBArch
	jal drawPixel
	addi $a0, $a0, -1
	addi $t0, $t0, 1
	j oBot
oLBArch:
#draw circle bottom left arch
	jal drawPixel
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	jal drawPixel
	addi $a0, $a0,-1
	addi $a1, $a1,-1
	jal drawPixel
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	jal drawPixel
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	jal drawPixel
	
oDone:
#circle is done now jump back also check if win		
	jal checkWin
	
	li $a0, 64
	li $a1, 64
	li $a2, GREEN
	addi $t8, $t8, 1
	j loop
	
########Chooses color based on shape, x is red circle is blue	
colorPicker:
	addi $sp, $sp, -4
	sw $ra, ($sp)
		beq $t7, 0, red
		beq $t7, 1, blue
	red:
		li $a2, RED
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra	
	blue:
		li $a2, BLUE
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
saveSpot:
##saves where items are placed. Grid behavior s0-7 and t6, 1 if x 2 if circle        RED = x    BLUE = circle
##each method is named after the register it is for, it saves the color and location of the drawn shape (color indicates shape)
	addi $sp, $sp, -4
	sw $ra, ($sp)
		##checks if  s1
		s0:
			bge $a0, 43, s1 #s1 loop
			bge $a1, 43, s1
			
				beq $a2, RED, s0r
				beq $a2, BLUE, s0b
				s0r: li $s0, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s0b: li $s0, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		s1:
			bge $a0, 86, s2 #s2 loop
			bge $a1, 43, s2
			
			beq $a2, RED, s1r
				beq $a2, BLUE, s1b
				s1r: li $s1, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s1b: li $s1, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		s2:
			bge $a0, 127, s3 #s3 loop
			bge $a1, 43, s3
			beq $a2, RED, s2r
				beq $a2, BLUE, s2b
				s2r: li $s2, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s2b: li $s2, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		s3:
			bge $a0, 43, s4 #s4loop
			bge $a1,86, s4
			beq $a2, RED, s3r
				beq $a2, BLUE, s3b
				s3r: li $s3, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s3b: li $s3, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		s4:
			bge $a0, 86, s5 #s3 loop
			bge $a1, 86, s5
			beq $a2, RED, s4r
				beq $a2, BLUE, s4b
				s4r: li $s4, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s4b: li $s4, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		s5:
			bge $a0, 128, s6 #s3 loop
			bge $a1, 86, s6
			beq $a2, RED, s5r
				beq $a2, BLUE, s5b
				s5r: li $s5, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s5b: li $s5, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		s6:
			bge $a0, 43, s7 #s3 loop
			bge $a1, 128, s7
			beq $a2, RED, s6r
				beq $a2, BLUE, s6b
				s6r: li $s6, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s6b: li $s6, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		s7:bge $a0, 86, t6 #s3 loop
			bge $a1, 128, t6
			beq $a2, RED, s7r
				beq $a2, BLUE, s7b
				s7r: li $s7, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				s7b: li $s7, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
		t6:
			beq $a2, RED, t6r
				beq $a2, BLUE, t6b
				t6r: li $t6, 1
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				t6b: li $t6, 2
				lw $ra, ($sp)
				addi $sp, $sp, 4
				jr $ra
				
						
##hard coded to check the grid for every possible win in order from top left to bottomr right
##if a win was declared a line is drawn through all pieces								
checkWin:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t0, 0
	li $a2, MAGENTA
	vert1:
		beq $s0, $s3, vert1con2
		j vert2
		vert1con2:
		li $a0, 22
		li $a1, 0
		beq $s3, $s6, drawVert
		
	
	vert2:
		beq $s1, $s4, vert2con2
		j vert3
		vert2con2:
		li $a0, 64
		li $a1, 0
		beq $s4, $s7, drawVert
		
	vert3:
		beq $s2, $s5, vert3con2
		j hor1
		vert3con2:
		li $a0, 107
		li $a1, 0
		beq $s5 $t6, drawVert
		
	hor1:
		beq $s0, $s1, hor1con2
		j hor2
		hor1con2:
			li $a0, 0
			li $a1, 22
			beq $s1, $s2, drawHori
			
	hor2:
		beq $s3, $s4, hor2con2
		j hor3
		hor2con2:
			li $a0, 0
			li $a1, 64
			beq $s4, $s5, drawHori
			
	hor3:
		beq $s6, $s7 hor3con2
		j diagR
		hor3con2:
			li $a0, 0
			li $a1, 108
			beq $s7, $t6, drawHori
			
	diagR:
		beq $s2, $s4, diagRcon2
		j diagL
		diagRcon2:
			li $a0, 127
			li $a1, 0
			li $t0, 0
			beq $s4, $s6, drawDiagR
			
	diagL:
		beq $s0, $s4, diagLcon2
		j backj
		diagLcon2:
			li $a0, 0
			li $a1, 0
			beq $s4, $t6, drawDiagL
			j backj
			
#draws vertical winning bar
 drawVert:
 	
 	beq $t0, 128, backj
 	jal drawPixel
 	addi $t0, $t0, 1
 	addi $a1, $a1, 1
 	j drawVert
 #draws horizontal winning bar	
 drawHori:
 	beq $t0, 128, backj
 	jal drawPixel
 	addi $t0, $t0, 1
 	addi $a0, $a0, 1
 	j drawHori
 #draws left diagonal winning bar
 drawDiagL: 
 	beq $t0, 512, backj
 	jal drawPixel
 	addi $t0, $t0, 1
 	addi $a0, $a0, 1
 	addi $a1, $a1, 1
 	j drawDiagL
 #draws right diagonal winning bar	
 drawDiagR: 
 	beq $t0, 512, backj
 	jal drawPixel
 	addi $t0, $t0, 1
 	addi $a0, $a0, -1
 	addi $a1, $a1, 1
 	j drawDiagR
#fixes stack pointer and jumps back
backj:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra										
												
														
																
																		
																				
																							
