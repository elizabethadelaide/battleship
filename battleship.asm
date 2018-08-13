#Test of function
.data
#String helpers
newline: .asciiz "\n"
space: .asciiz " "
twospaces: .asciiz "_ "
player: .asciiz "Player: " #la $a0, player; li $v0, 4; syscall
computer: .asciiz "Computer: "
miss: .asciiz "Miss!\n"
hit: .asciiz "Hit!\n"
youhavesunka: .asciiz "You have sunk a "
#User turn order
userturn: .asciiz "Would you like to shoot first (y/n)?: "
#Top of printboard
toprow: .asciiz "   0 1 2 3 4 5 6 7 8 9   0 1 2 3 4 5 6 7 8 9"
userprompt: .asciiz "Please enter coordinates. If you could use UPPER case letter.\n"
userPlaceCoordinates: .asciiz "Enter Coordinates for "
userPromptDirection: .asciiz "	Which Direction NESW? "
computerWins: .asciiz "Computer Wins\n"
playerWins: .asciiz "Player Wins\n"
leftColumnHelper: .asciiz ": |"
enterRandomSeed: .asciiz "Please enter random seed: "
#Array data
size: .word 400
playerboard: .space 400
computerboard: .space 400
playershots: .space 400
computershots: .space  400
computerCoordinates: .space 4 #For that point where I run out of registers
argumentFourMemory: .space 4 #Where I need one more argument
m_w: .space 4 #one of the random seeds
m_z: .space 4 #the other random seeds

userresponse: .space 12

#Break Code
# li $v0, 4
# la $a0, computerWins
# syscall
# li $v0, 12
#syscall
#add $s5, $ra, $0
#add $a0, $s0, $0
#add $a1, $s0, $0
#jal PRINTBOARD
#add $ra, $s5, $ra
# li $v0, 4
# la $a0, computerWins
# syscall
# li $v0, 12
#syscall
#add $ra, $s5, $0



.text
main:
	#Intitialise random number generator
#	li $v0, 30 Our simulator cannot query system time, so I'll ask for a user input
#	syscall
	la $a0, enterRandomSeed
	li $v0, 4
	syscall
	li $v0, 5
	syscall #Get integer from user
	la $t0, m_w
	add $a0, $v0, $0
	sw $a0, 0($t0)
	li $v0, 1
	syscall #print integer
#	li $v0, 30
#	syscall
	li $v0, 4
	la $a0, newline
	syscall #print new line
	li $v0, 4
	la $a0, enterRandomSeed
	syscall #Read second see
	li $v0, 5
	syscall
	add $a0, $v0, $0
	la $t1, m_z
	sw $a0, 0($t1)
	li $v0, 1
	syscall #print second integer
	#lw $t0, size #pointer Size of array to t0
	la $s0, playerboard #Address of playerboard
	la  $s1, computerboard
	la $s2, playershots
	la $s3, computershots

	#Set random seed:
	
	#Get argument for fillboard
	#Fill playerboard
	add $a0, $s0, $0
	jal FILLBOARD #Fill playerboard with 0
	#Fill computerboard
	add $a0, $s1, $0
	jal FILLBOARD
	#fill playershots
	add $a0, $s2, $0
	jal FILLBOARD
	#fill computershots
	add $a0, $s3, $0

	#placeships
	#placehips for playerboard
	add $a0, $s0, $0
	jal PLACEPLAYERSHIPS
	#Place ships for computerboard
	add $a0, $s1, $0
	jal PLACESHIPS
	
	add $s8, $0, $0	
add $a0, $s0, $0
add $a1, $s2, $0
add $s5, $ra, $0
jal PRINTBOARD
add $ra, $s5, $0
	#Get Player's turn order	
	USERTURNLOOP:
		addi $t1, $0, 121 #Ascii value for 'y'
		beq $t1, $s8, USERTURNEXIT #if userResponse = 'y'
		addi $t1, $0, 110 #ascii value for 'n'
		beq $t1, $s8, USERTURNEXIT #if userResponse = 'n'
		#primt prompt
		li $v0, 4
		la $a0, userturn #load prompt
		syscall
		#Get user answer
		li $v0, 12
		syscall
		add $s8, $v0, $0 #Put user answer to t0
		#Print user answer
		li $v0, 11
		add $a0, $s8, $0
		syscall
		#Print new line
		li $v0, 4 
		la $a0, newline
		syscall
		j USERTURNLOOP
	USERTURNEXIT:
	#Get turn Order from user input
	addi $t1, $0, 2
	div $t0, $t2
	mfhi $s4 #get turn input

	addi $s8, $0, -1  #previousHit = -1
	
	add $s5, $0, $0 #set winFlag to 0
	WINFLAGLOOP:
		bne $s5, $0, WINFLAGEXIT #While winflag == 0
		add $s6, $0, $0 #number of turns = 0
		NUMBERTURNSLOOP:
			addi $t0, $s6, -2 #numberof turns - 2
			beq $t0, $0, NUMBERTURNSWINCASE #Exit on number of turns >= 2
			bne $s5, $0, NUMBERTURNSWINCASE
			NUMBERTURNSCONTINUE:
				add $s7, $0, $0 #hitflag = 0;
				sub $t0, $s4, $s6 #turnOrder - numberOfTurns
				beq $t0, $0, PLAYERTURNLOOP
				j COMPUTERTURNLOOP
			PLAYERTURNLOOP:
				bne $s7, $0, PLAYERTURNEXIT #while hitFlag == 0
				jal USERCOORDINATES #userLocation = userCoordinates
				add $t1, $v0, $0 #get userlocation
				add $a0, $s1, $0 #arg[0] = computerboard
				add $a1, $s2, $0 #arg[1] = playershots
				add $a2, $t1, $0 #arg[2] = userLocation
				addi $a3, $0, 1 #arg[3] = whoami
				jal CHECKHIT #checkHit(computerbaord, playershors, userlocation, 1);
				add $s7, $v0, $0 #hitFlag = ^
				j PLAYERTURNLOOP
			PLAYERTURNEXIT:
				add $a0, $s2, $0 #arg[0] = playershots
				jal CHECKWIN #CHECKwIN
				add $s5, $v0, $0 #winFlag = chekcWin(playershots);
				addi $s6, $s6, 1 #numberofturns++
				j TURNEXIT
			COMPUTERTURNLOOP:
				bne $s7, $0, COMPUTEREXIT #while hitFlag == 0
				add $a0, $s3, $0 #arg[0] = computershots
				add $a1, $s8, $0 #arg[1] = previousHit
				jal GETCOMPUTERCOORDINATES #getComputerCoordinates(computershots, previousHit);
				la $t0, computerCoordinates #Get word in memory
				sw $v0, 0($t0) #Save previous hit in memory			
				add $a0, $s0, $0 #arg[0] = playerboard
				add $a1, $s3, $0 #arg[1] = computerShots
				add $a2, $v0, $0 #arg[2] = computerCoordinates
				addi $a3, $0, 0 #arg[3] = 1
				jal CHECKHIT #checkHit(playerboard, computershots, computerCoordinates, 0);
				add $s7, $v0, $0 #hitFlag = checkHit
				addi $t0, $0, 1
				bne $s7, $t0, REMEMBERHIT #save last hit
				addi $s8, $0, -1
				j REMEMBERHITEXIT
				REMEMBERHIT:
					la $t0, computerCoordinates #Load address of computerCoordinates
					lw $t0, 0($t0) #get computerCoordinates from memory
					add $s8, $t0, $0 #previousHit = computerCoordinates
					j REMEMBERHITEXIT
				REMEMBERHITEXIT:
					#Print Boards:
					j COMPUTERTURNLOOP
				COMPUTEREXIT:
					add $a0, $s3, $0 #arg[0]  =computershots
					jal CHECKWIN
					addi $t0, $0, 2 #2
					mult $v0, $t0 #checkWin(computershots) * 2
					mflo $s5 #get winFlag
					addi $s6, $s6, 1 #NumberOfTurns++
					j TURNEXIT
				TURNEXIT:
				add $a0, $s0, $0 #arg[0]  = playerboard
				add $a1, $s2, $0 #arg[1] = playershots
				jal PRINTBOARD
		j NUMBERTURNSLOOP
		NUMBERTURNSWINCASE:
			add $s6, $0, $0 #Numberof turns = 0
			j WINFLAGLOOP
	WINFLAGEXIT:
		#Print win conditions, I'll get to it.
		beq $s5, $0, COMPUTERWINS
		j PLAYERWINS
		COMPUTERWINS:
			la $a0, computerWins
			li $v0, 4
			syscall
			 j FINALEXIT
		PLAYERWINS:
			la $a0, playerWins
			li $v0, 4
			syscall
			j FINALEXIT
		FINALEXIT:
			li $v0, 10 #equiv of return 0;
			syscall
			

# I don't know why I wrote this:
#			NUMBERTURNSREALLYCONTINUE:
#				bne $s5, $0, NUMBERTURNSEXIT #on numberofturns < 2 && winFlag == 0
#				j NUMBERTURNSREALLYCONTINUE
#			NUMBERTURNSEXIT:


	#for (i = 0; i < 100; i++)
	# if i % 10 = 0{ printf("%i\n", array[i]);}
	# else{ printf("%i ", array[i]);}
#	add $t1, $0, $0 #i = 0
#	addi $t2, $t1, -99 #i - 99
#	addi $t3, $0, 10 #t3 = 0
#PRINTLOOP:
#	beq $0, $t2, PRINTEXIT
#	sll $t4, $t1, 2 #get correct offset
#	add $t5, $t4, $s0 #array[i]
#	lw $a0, 0($t5)
#	li $v0, 1
#	syscall
#	div $t1, $t3 #i/10
#	mfhi $t4 #$t4 = t2%t3
#	addi $t4, $t4, -9 #if t4 == 9
#	addi $t1, $t1, 1 #i++
#	addi $t2, $t1, -100 #
#	beq $t4, $0, PRINTEQUALSZERO
#	j PRINTDOESNOTEQUALZERO
#	PRINTEQUALSZERO:
#		la $a0, newline
#		li $v0, 4
#		syscall
#		j PRINTLOOP
#	PRINTDOESNOTEQUALZERO:
#		la $a0, space
#		li $v0, 4
#		syscall
#		j PRINTLOOP	
#PRINTEXIT:
#	li $v0, 10
#	syscall
#	
	
	

FILLBOARD:
	addi $sp, $sp, -4
	sw $s0, 0($sp) 
	#mv $t0, $a0 #Get argument to better register]
	add $t0, $a0, $0
	add $t1, $0, $0 #Get fill number
	add $t2, $0, $0 #loop number
	addi $t3, $t2, -100 #check case
	add $s0, $ra, $0 #Save return address
FILLLOOP:
	beq $0, $t3, FILLEXIT #for(i = 0; i < 100; i++)
	sll $t4, $t2, 2 #Get offset from address
	add $t5, $t4, $t0 #address to get
	sw $t1, 0($t5) #array[i] = 0
	addi $t2, $t2, 1 #i++
	addi $t3, $t2, -100
	j FILLLOOP
FILLEXIT:
	add $ra, $s0, $0 #Get back return address
	lw $s0, 0($sp)
	addi $sp, $sp, 4 #Pop back the stack
	jr $ra #Return to main

PLACEPLAYERSHIPS:
	#PUSCH that stack
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	#for (length = 5; length >= 2; length--){
	add $s2, $0, $a0
	addi $s3, $0, 5
	add $s0, $a0, $0
	PLACEPLAYERSHIPSLENGTHLOOP:
		addi $t0, $0, 1
		beq $t0, $s3, PLACEPLAYERSHIPSLENGTHEXIT
		addi $s1, $0, 1 #k = 1
		PLACEPLAYERSHIPSKLOOP:
			beq $0, $s1, PLACEPLAYERSHIPSKEXIT #while k!=0
			la $a0, userPlaceCoordinates
			li $v0, 4 
			syscall #Print place coordinates prompt
			#Calculate length:
			addi $t0, $0, 2
			mult $t0, $s3
			mflo $t1 #2 * length
			addi $t1, $t1, -2
			#Print length
			li $v0, 1
			add $a0, $t1, $0
			syscall #print ship's name
			li $v0, 12 
			#Get user coordinates:
			syscall #Read character
			add $t0, $v0, $0
			add $a0, $t0, $0
			li $v0, 11
			syscall #print character
			li $v0, 12
			syscall
			add $t1, $v0, $0 
			add $a0, $v0, $0
			li $v0, 11
			syscall #print second character
			addi $t0, $t0, -65
			addi $t2, $0, 10
			mult $t0, $t2
			mflo $t0 #u[0] - 65 *10
			addi $t1, $t1, -48
			add $t0, $t1, $t0 #position
			#Get user direction
			#prompt
			li $v0, 4
			la $a0, userPromptDirection
			syscall #Print direction prompt
			li $v0, 12
			syscall
			add $t1, $v0, $0 #Get direction character
			li $v0, 11 #print character
			add $a0, $t1, $0
			syscall
			#print newline
			li $v0, 4
			la $a0, newline
			syscall
			addi $t2, $0, 78
			beq $t1, $t2, PLACEPLAYERSHIPSNORTH
			addi $t2, $0, 69
			beq $t2, $t1, PLACEPLAYERSHIPSEAST
			addi $t2, $0, 83
			beq $t2, $t1, PLACEPLAYERSHIPSSOUTH
			addi $t2, $0, 87
			beq $t2, $t1, PLACEPLAYERSHIPSWEST
			j PLACEPLAYERSHIPSKLOOP
			PLACEPLAYERSHIPSNORTH:
				addi $t1, $0, 1
				j PLACEPLAYERSHIPSEXITDIRECTION
			PLACEPLAYERSHIPSEAST:
				add $t1, $0, $0
				j PLACEPLAYERSHIPSEXITDIRECTION
			PLACEPLAYERSHIPSSOUTH:
				addi $t1, $0, 3
				j PLACEPLAYERSHIPSEXITDIRECTION
			PLACEPLAYERSHIPSWEST:
				add $t1, $0, 2
				j PLACEPLAYERSHIPSEXITDIRECTION
			PLACEPLAYERSHIPSEXITDIRECTION:
			#TryDirection argumnets
			add $a0, $s1, $0 #k
			add $a1, $t1, $0 #orienctiona
			add $a2, $t0, $0 #position
			add $a3, $s3, $0 #length 
	#		add $a3, $s2, $0 #me Board, passed implicitly:
			add $s4, $ra, $0 #save return address
			jal TRYDIRECTION
			add $s1, $v0, $0
			add $ra, $s4, $0
			add $a0, $s2, $0 #Print the board
			add $a1, $s2, $0 #Print it twice, so I don't have to write another function
			add $s4, $ra, $0
			jal PRINTBOARD
			add $ra, $s4, $0
		j PLACEPLAYERSHIPSKLOOP
		PLACEPLAYERSHIPSKEXIT:
		addi $s3, $s3, -1
	j PLACEPLAYERSHIPSLENGTHLOOP
	PLACEPLAYERSHIPSLENGTHEXIT:
	#pOP STACK
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	jr $ra
		#while (k != 0){
			#get user input
			#convert user input
		#trydirection
	

RANDNUMBER:
#Just the given random number generator
#add $t0, $0, $a0
#add $t5, $0, 1000
##li $v0, 5
##syscall
#add $a0, $0, $t0
#M_w:
#la $t0, m_w
#lw $t0, 0($t0)
#andi $t2, $t0, 65535
#add $t3, $0, 36969
#mult $t2, $t3
#mflo $t2
#srl $t3, $t0, 16
#add $t4, $t2, $t3
##beq $t2, $t4, M_w
#div $t4, $t5
#mfhi $t4
#la $t0, m_w
#sw $t4, 0($t0)
#
#add $t5, $0, 999
#M_z:
#la $t1, m_z
#lw $t1, 0($t1)
#andi $t2, $t1, 65535
#add $t3, $0, 18000
#mult $t2, $t3
#mflo $t2
#srl $t3, $t1, 16
#add $t4, $t2, $t3
##beq $t2, $t4, M_z
#div $t4, $t5
#mfhi $t4
#
#la $t0, m_z
#sw $t4, 0($t0)
#sll $t3, $t1, 16
#add $t2, $t3, $t0
#sub $t0, $a0, $a1 #Max - min
#div $t2, $t0
#mfhi $t2
#add $t2, $t2, $a1
##return values to address
#add $v0, $t2, $0
#jr $ra	
	#m_z = (36969 *(m_z & 65535) + (m_z >> 16))%32768
	la $t0, m_z
	lw $t3, 0($t0)
	andi $t1, $t3, 15537
	addiu $t2, $0, 23625
	multu $t1, $t2
	mflo $t1
	sw $t1, 0($t0)
	la $t4, m_z
	lw $t0, 0($t4)
	andi $t0, $t0, 65535
	addiu $t3, $0, 30803
	multu $t0, $t3
	mflo $t0
	sw $t0, 0($t4)
	sll $t1, $t1, 16
	addu $t1, $t1, $t0
	subu $t0, $a0, $a1
	divu $t1, $t0
	mfhi $t1
	addu $v0, $a1, $t1		
	jr $ra	

PLACESHIPS:
	#Push stack
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)

	#get argument
	add $s0, $a0, 0
	#for (length = 5; length >= 2; length--){
	addi $s1, $0, 5 #length = 5
	
	PLACESHIPSLENGTHLOOP:
		addi $t0, $s1, -1
		beq $t0, $0, PLACESHIPSLENGTHEXIT #on length < 1
		addi $s2, $0, 5 #k = 5
		PLACESHIPSKLOOP:
			addi $t0, $0, 5
			bne $t0, $s2, PLACESHIPSKEXIT #when k != 5
			addi $a0, $0, 99 #Max value for position
			add $a1, $0, $0 #Min Value for position
			add $s5, $ra, $0
			jal RANDNUMBER #Call RANDNUMBER
			add $s3, $v0, $0 #position = RANDNUMBER(99,0)
			addi $a0, $0, 3 #Max value for orientation
			add $a1, $0, $0 #Min value for orientation
			jal RANDNUMBER #orientation = RANDNUMBER(3,0)
			add $s4, $v0, $0 #get value of orientiation
			add $ra, $s5, $0 #get back return address
			
			addi $s2, $0, 1 #k = 1
			PLACESHIPSTRYDIRECTIONLOOP:
				beq $s2, $0, PLACESHIPSTRYDIRECTIONEXIT #k == 0
				addi $t0, $s2, -5 #for checking k <= 4
				beq $t0, $0, PLACESHIPSTRYDIRECTIONEXIT #k > 4
				add $a0, $s2, $0 #arg[0] = k
				add $a1, $s4, $0 #arg[1] = orientation
				add $a2, $s3, $0 #arg[2] = position
				add $a3, $s1, $0 #arg[3] = length
				#add $a4, $s0, $0 #arg[4] = myBoard
				#la $t0, argumentFourMemory
				#sw $s
				add $s5, $ra, $0 #Save return address
				jal TRYDIRECTION #Try a direction
				add $s2, $v0, $0 #get k
				add $ra, $s5, $0 #Get back return address
				addi $s4, $s4, 1 #orientation++
				j PLACESHIPSTRYDIRECTIONLOOP
			PLACESHIPSTRYDIRECTIONEXIT:
				j PLACESHIPSKLOOP
		PLACESHIPSKEXIT:
			addi $s1, $s1, -1
			j PLACESHIPSLENGTHLOOP
	PLACESHIPSLENGTHEXIT:
		#pop back the stack
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 24
		#return
		jr $ra

TRYDIRECTION:
	#PUSH stack
	addi $sp, $sp, -8 #allocate space for stack
	sw $s0, 0($sp)
	add $t9, $s0, $0 #Instead of using an argument, directly use $s1, before pushing the stack
	sw $s1, 4($sp)
	addi $t0, $0, 4
	div $a1, $t0
	mfhi $a1 #ori = ori %4	

	#Imma use straight arguments, see how that works
	#for(i = 0; i < length; i++)
	add $t0, $0, $0 #i = 0
	TRYDIRECTIONLOOP:
		sub $t1, $t0, $a3
		bgez $t1, TRYDIRECTIONEXIT #on i i>= length
		#calculate offset:
		addi $t1, $0, 2
		div $a1, $t1 #ori/2
		mfhi  $t1 #ori%2
		mult $t1, $t0 #i*(ori%2)
		mflo $t1 #Get product
		addi $t2, $0, 10
		mult $t1, $t2 #i*(ori%2)*10
		mflo $t1 #get product
		
		addi $t2, $0, 2
		div  $a1, $t2 #ori/2
		mfhi $t2 #ori%2
		addi $t2, $t2, -1
		mult $t0, $t2 #i*((ori%2)-1)
		mflo $t2 #get product
		add $t1, $t1, $t2 #offset
		
		addi $t2, $a1, -1
		bgtz $t2, TRYDIRECTIONDONTSWITCH
		TRYDIRECTIONSWITCH:
			addi $t2, $0, -1
			mult $t1, $t2
			mflo $t1
			j TRYDIRECTIONDONTSWITCH
		TRYDIRECTIONDONTSWITCH:
			add $s0, $a2, $t1 #newposition = pos + offset
			#add $t3, $0, $t1
			#Cases for conflicts:
			#*tempBoard != 0
			#newposition < 0
			bltz $s0, TRYDIRECTIONOUTOFBOUNDS
			#newposition > 100
			addi $t1, $s0, -100
			bgtz $t1, TRYDIRECTIONOUTOFBOUNDS
			#newposition % 10 == 0
			addi $t1, $0, 10
			div $s0, $t1
			mfhi $t1 #newposition % 10
			beq $t1, $0, TRYDIRECTIONLEFTRIGHTOUTOFBOUNDS
			#newposition % 10 ==  9
			addi $t1, $t1, -9
			beq  $t1, $0, TRYDIRECTIONLEFTRIGHTOUTOFBOUNDS
			TRYDIRECTIONCHECKPREVIOUS:
			sll $t1, $s0, 2
			add $s1, $t9, $t1 #tempBoard = theBoard+newposition
			lw $t1, 0($s1) #Load *tempBoard
			bne $t1, $0, TRYDIRECTIONCONFLICT
			addi $t0, $t0, 1
			j TRYDIRECTIONLOOP
		TRYDIRECTIONLEFTRIGHTOUTOFBOUNDS:
			addi $t2, $0, 2
			div $a1, $t2
			mfhi $t3 #ori%2
			beq $t3, $0, TRYDIRECTIONOUTOFBOUNDS
			j TRYDIRECTIONCHECKPREVIOUS
		TRYDIRECTIONOUTOFBOUNDS:
			#i%length != 0
			div $t0, $a3 #i/length
			mfhi $t1
			bne $0, $t1, TRYDIRECTIONCONFLICT
		#	addi $t0, $t0, 1
			j TRYDIRECTIONCHECKPREVIOUS
		TRYDIRECTIONCONFLICT:
			addi $t0, $0, 1000
			addi $a0, $a0, 1
			addi $t0, $t0, 1
			j TRYDIRECTIONLOOP
	TRYDIRECTIONEXIT:
	#if i< 1000:
	addi $t0, $t0, -1000
	bgez $t0, TRYDIRECTIONWRITEEXIT
	#j TRYDIRECTIONWRITEEXIT
	#for (i = 0; i < length; i++){
	add $t0, $0, $0 #i = 0
	TRYDIRECTIONWRITELOOP:
		beq $t0, $a3, TRYDIRECTIONWRITEEXIT
		
		#calculate offset:
		addi $t1, $0, 2
		div $a1, $t1 #ori/2
		mfhi  $t1 #ori%2
		mult $t1, $t0 #i*(ori%2)
		mflo $t1 #Get product
		addi $t2, $0, 10
		mult $t1, $t2 #i*(ori%2)*10
		mflo $t1 #get product
		
		addi $t2, $0, 2
		div  $a1, $t2 #ori/2
		mfhi $t2 #ori%2
		addi $t2, $t2, -1
		mult $t0, $t2 #i*((ori%2)-1)
		mflo $t2 #get product
		add $t1, $t1, $t2 #offset
		
		addi $t2, $a1, -1
		bgtz $t2, TRYDIRECTIONWRITEDONTSWITCH
		TRYDIRECTIONWRITESWITCH:
			addi $t2, $0, -1
			mult $t1, $t2
			mflo $t1
			j TRYDIRECTIONWRITEDONTSWITCH
		TRYDIRECTIONWRITEDONTSWITCH:
			add $s0, $a2, $t1 #newposition = pos + offset
			sll $s0, $s0, 2
			add $s1, $t9, $s0 #tempBoard = theBoard+newposition
			sll $t1, $a3, 1 #2 * length
			addi $t1, $t1, -2 #2*length - 2
			sw $t1, 0($s1)
			add $a0, $0, $0 #iteration = 0
			addi $t0, $t0, 1
		j TRYDIRECTIONWRITELOOP
	TRYDIRECTIONWRITEEXIT:
		#POP Stack
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
	
		add $v0, $a0, 0
		jr $ra #return iteration

#gets user inputs and outputs number on array
USERCOORDINATES:
	#PUSH Stack #No stack pushing
	
	#Print prompt
	li $v0, 4
	la $a0, userprompt
	syscall
	#Get user response
	li $v0, 12
	addi $a1, $0, 3
	syscall
	add $a0, $v0, $0
	li $v0, 11
	syscall
	add $t1, $a0, $0
	li $v0, 12
	syscall
	add $a0, $v0, $0
	li $v0, 11
	syscall
	add $t2, $a0, $0
	#ASCII conversion:
	#((u[0] - 65)*10) + (u[1] - 48)
	addi $t1, $t1, -65
	addi $t3, $0, 10
	mult $t1, $t3
	mflo $t1
	addi $t2, $t2, -48
	add $t1, $t1, $t2
	add $v0, $t1, $0
	jr $ra


PRINTBOARD: #Print Horizantally
	#PUSH Stac0
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	add $s0, $a0, $0
	add $s1, $a1, $0
	li $v0, 4
	la $a0, newline
	syscall
	#Print Top Row
	#printf("	0 1 2 3 4 5 6 7 8 9	0 1 2 3 4 5 6 7 8 9");
	li $v0, 4
	la $a0 toprow
	syscall	
	#For (k = 0; k < 10; k++){ #Each row
	add $t1, $0, $0 #k = 0
	PRINTBOARDKLOOP:
		addi $t0, $0, 10
		beq $t1, $t0, PRINTBOARDKEXIT #Exit loop
		#printf("\n");
		la $v0, 4
		la $a0, newline
		syscall
		#For (n = 0; n < 2; n++){ #Each board
		add $t2, $0, $0 #n = 0
		PRINTBOARDNLOOP:
			addi $t0, $0, 2
			beq $t2, $t0, PRINTBOARDNEXIT	
			#Choose board to print
			beq $t2, $0, PRINTBOARDLEFTBOARD
			j PRINTBOARDRIGHTBOARD
			PRINTBOARDLEFTBOARD:
				add  $s2, $s0, $0
				j PRINTBOARDLEFTRIGHTEXIT
			PRINTBOARDRIGHTBOARD:
				add $s2, $s1, $0
				j PRINTBOARDLEFTRIGHTEXIT
			PRINTBOARDLEFTRIGHTEXIT:
			#Print right column
			#printf("%c: |", k + 65);
			la $v0, 4
			addi $a0, $t1, 65
			li $v0, 11
			syscall
			la $a0, leftColumnHelper
			li $v0, 4
			syscall
			#For (i = 0; i < 10; i++){ #Each item in the board
			add $t3, $0, $0
			PRINTBOARDILOOP:
				addi $t0, $0, 10
				beq $t3, $t0, PRINTBOARDIEXIT
				#Get myShots[i + 10 *k]
				mult $t1, $t0 #k * 10
				mflo $t0
				add $t0, $t0, $t3 #i + 10*k
				sll $t0, $t0, 2
				add $t0, $s2, $t0 #myShots[i + 10*k]
				lw $t0, 0($t0)
				#if(my Shots[i + 10*k] == 0){
				beq $t0, $0, PRINTBOARDPRINTSPACE
				j PRINTBOARDPRINTNUMBER
				PRINTBOARDPRINTSPACE:
					#printf("  ");
					li $v0, 4
					la $a0, twospaces
					syscall	
					j PRINTBOARDPRINTEXIT			
				#else
				PRINTBOARDPRINTNUMBER:
				#printf"%i ", myShots[n]);
					li $v0, 1
					add $a0, $t0, $0
					syscall
					li $v0, 4
					la $a0, space
					syscall	
					j PRINTBOARDPRINTEXIT
				PRINTBOARDPRINTEXIT:
				addi $t3, $t3, 1
			j PRINTBOARDILOOP
			PRINTBOARDIEXIT:
			addi $t2, $t2, 1
		j PRINTBOARDNLOOP
		PRINTBOARDNEXIT:
		addi $t1, $t1, 1
	j PRINTBOARDKLOOP
	PRINTBOARDKEXIT:
	#POP Stack
	la $a0, newline
	li $v0, 4
	syscall
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra
				
CHECKWIN:
	addi $t1, $0, 100 # $t1 = 100
	add $t0, $0, $0 # i = 0
	add $t4, $0, $0 # n = 0
	addi $t2, $0, 2 # $t2 = 2
	CHECKWINLOOP:
		beq $t0, $t1, CHECKWINLOOPEXIT # i<100
		sll $t5, $t0, 2
		add $t3, $a0, $t5
		lw $t3, 0($t3)
		beq $t3, $t2, ADDVALUE
		j DONTADDVALUE
			ADDVALUE:
			addi $t4, $t4, 1 # n++
		DONTADDVALUE:
		addi $t0, $t0, 1 # i++
		j CHECKWINLOOP
	CHECKWINLOOPEXIT:
		addi $t2, $0, 14 # $t2 = 14
		beq $t4, $t2, CHECKWINRETURNONE
		j CHECKWINRETURNZERO
		CHECKWINRETURNONE:
			addi $v0, $0, 1
			j CHECKWINEXIT
		CHECKWINRETURNZERO:
			add $v0, $0, $0
			j CHECKWINEXIT
		CHECKWINEXIT:
		jr $ra #Return to main
		
		
CHECKHIT:								#need 5 registers for printf statements, have to push stack
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
#li $v0, 5
#syscall
	add $s1, $a0, $0
	
	add $s0, $a0, $0
	add $t0, $0, $0 # n = 0
	sll $t1, $a2, 2
	add $t1, $a0, $t1 
	lw $t1, 0($t1)						#loading herBoard into t1
	sll $t2, $a2, 2
	add $t2, $a1, $t2
	lw $s2, 0($t2)						#loading myBoard into t2
	addi $s0, $t1, 0				#herBoard[myCoordinates]-1
	addi $t3, $0, 2						#t3 = 2
	div  $t1, $t3 #ori/2				 
	mfhi $t3 #ori%2						#t3 = herBoard[myCoordinates]%2
	beq $t1, $0, CHECKHITNOHIT 			#herBoard[myCoordinates] == 0
	j CHECKHITMAYBE
		CHECKHITNOHIT:
			addi $t1, $t1, 1					#herBoard[myCoordinates]++
			sll $t2, $a2, 2
			add $t2, $s1, $t2
			sw $t1, 0($t2)
			addi $s2, $s2, 1					#myBoard[myCoordinates]++
			sll $t2, $a2, 2
			add $t2, $a1, $t2
			sw $s2, 0($t2)
			beq $a3, $0, CHECKHITPLAYER 		#if (whoami == 0)
		#printf(player:)
			li $v0, 4
			la $a0, player
			syscall
			j CHECKHITPRINTMISS
		CHECKHITPLAYER:
		#printf(computer:)
			li $v0, 4
			la $a0, computer
			syscall
			j CHECKHITPRINTMISS
		CHECKHITPRINTMISS:				
		#printf(miss)
			li $v0, 4
			la $a0, miss
			syscall
			add $v0, $0, 1	
			j CHECKHITEXIT	
		CHECKHITMAYBE:					
			beq $t3, $0, CHECKHITHIT			#herBoard[myCoordinates]%2 == 0
			j CHECKHITELSE
		CHECKHITHIT:
			addi $t1, $t1, 1					#herBoard[myCoordinates]++
			sll $t4, $a2, 2
			add $t4, $s1, $t4 
			sw $t1, 0($t4)						#loading herBoard into t1
	add $t2, $a1, $a2
			addi $t2, $0, 2						#myBoard[myCoordinates] = 2
			sll $t4, $a2, 2
			add $t4, $a1, $t4
			sw $t2, 0($t4)						#loading myBoard into t2
			beq $a3, $0, CHECKHITNOTCOMPUTER	#if (whoami == 0)
		#printf(player:)
			li $v0, 4
			la $a0, player 
			syscall
			j CHECKHITPRINTHIT
		CHECKHITNOTCOMPUTER:
		#printf(computer:)
			li $v0, 4
			la $a0, computer
			syscall
			j CHECKHITPRINTHIT
		CHECKHITPRINTHIT:
		#printf(hit)
			li $v0, 4
			la $a0, hit
			syscall
			add $t3, $0, $0						#i = 0
			addi $t4, $0, 100					#t4 = 100
			add $t0, $0, $0 #n = 0
			CHECKHITLOOP:
				beq $t3, $t4, CHECKHITLOOPEXIT 		#i<100
				sll $t5, $t3, 2
				add $t1, $s1, $t5 				
				lw $t1, 0($t1)						#herBoard[i]
				beq $t1, $s0, CHECKHITISHIT			#herBoard[i] == herBoard[myCoordinates]-1
			j CHECKHITISNOTHIT 
		CHECKHITISHIT: 
			addi $t0, $t0, 1					#n++
			j CHECKHITISNOTHIT 
		CHECKHITISNOTHIT:
			addi $t3, $t3, 1 					#i++			
			j CHECKHITLOOP
		CHECKHITLOOPEXIT:	
			beq $t0, $0, CHECKHITSUNK			#n==0
			j CHECKHITNOTSUNK
		CHECKHITSUNK:
		#printf (you have sunk...)
			li $v0, 4
			la $a0, youhavesunka
			syscall
			li $v0, 1 #print integer
			add $a0, $s0, $0
			syscall
			li $v0, 4
			la $a0, newline
			syscall
			#You
			j CHECKHITNOTSUNK
		CHECKHITNOTSUNK:
			addi $v0, $0, 2					#return 1
			j CHECKHITEXIT		
		CHECKHITELSE:
			addi $v0, $0, 0						#return 0
			j CHECKHITEXIT
		CHECKHITEXIT:
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			addi $sp, $sp, 12
			jr $ra 	#Return to main		

GETCOMPUTERCOORDINATES:
	#Push stack
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	#a0 = *board, a1 = previous hit
	#for (i = 0; i < 4; i++
	add $s0, $0, $0 #t = 0
	add $s2, $0, $a0
	add $s3, $0, $a1
	bltz $s3, GETCOMPUTERCOORDINATESALOOP
	GETCOMPUTERCOORDINATESILOOP:
		addi $t0, $0, 4
		beq $s0, $t0, GETCOMPUTERCOORDINATESIEXIT #on i == 4
		#calculate offset
		addi $t0, $0, 2 #offset =  (i%2)*10 + ((i%2)-1)
		div $s0, $t0
		mfhi $t0 #i%2
		addi $t1, $0, 10
		mult $t0, $t1	
		mflo $t1 #i%2  *10
		addi $t0, $t0, -1
		add $t0, $t0, $t1 #offset
		addi $t1, $s0, -1
		bgtz $t1,GETCOMPUTERCOORDINATESFLIP
		j GETCOMPUTERCOORDINATESEXITFLIP
		GETCOMPUTERCOORDINATESFLIP:
			addi $t1, $0, -1
			mult $t1, $t0
			mflo $t0
			j GETCOMPUTERCOORDINATESEXITFLIP
		GETCOMPUTERCOORDINATESEXITFLIP:
		#calculate new position:
		add $t0, $s3, $t0 #new position
		bltz $t0, GETCOMPUTERCOORDINATESIEND
		addi $t1, $t0, -100
		bgez $t1, GETCOMPUTERCOORDINATESIEND
		add $s1, $t0, $0 #The value that might be returne
		sll $t0, $t0, 2 #Adjust for words
		add $t0, $s2, $t0 #Location in memory
		lw $t0, 0($t0) #value
		beq $t0, $0, GETCOMPUTERCOORDINATESIEXIT
		addi $t0, $0, 3 #for checking if i == 3	
		bne $s0, $t0, GETCOMPUTERCOORDINATESIEND
		j GETCOMPUTERCOORDINATESALOOP
		GETCOMPUTERCOORDINATESALOOP:
			addi $a0, $0, 99 #Max = 99 for rand number	
			add $a1, $0, $0 #Min = 0
			add $s4, $0, $ra #save return address
			jal RANDNUMBER
			add $ra, $0, $s4 #Get back return address
			add $s1, $0, $v0 #Get random number
			sll $t0, $s1, 2 #Get memory offset
			add $t0, $s2, $t0 #Get memory address
			lw $t0, 0($t0) #Get value
			beq $t0, $0, GETCOMPUTERCOORDINATESIEXIT
			j GETCOMPUTERCOORDINATESALOOP
		GETCOMPUTERCOORDINATESIEND:
			addi $s0, $s0, 1
			j GETCOMPUTERCOORDINATESILOOP
	GETCOMPUTERCOORDINATESIEXIT:
		add $v0, $s1, $0
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
		jr $ra #Return coordinates

		

