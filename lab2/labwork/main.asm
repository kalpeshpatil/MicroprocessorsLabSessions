;---------------------------------------------------------------
;TITLE: PRELAB2
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------

	LED EQU P1

	ORG 00H
	LJMP MAIN

DELAY:			;generate delay
	USING 0
	PUSH PSW	;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	PUSH AR3
	PUSH B
	MOV A, 4FH	; D
	MOV B, #10	
	MUL AB;      No. of times 50ms blocks to be executed to generate D/2 sec delay
	MOV R3, A
	
	BACK2:						;;upper loop running 10*D times
	MOV R2,#200
	BACK1:						;inner loop of 50ms delay
		MOV R1,#0FFH
		BACK:					;inner to inner loop
			DJNZ R1, BACK
		DJNZ R2, BACK1
	DJNZ R3, BACK2
	
	
	POP B  ;restoring register values
	POP AR3
	POP AR2
	POP AR1
	POP PSW 
	RET
	
	


Display:			;displaying number on LED
	USING 0	
	PUSH PSW		;;to make sure valuse of registers are stored somewhere
	PUSH AR1
	PUSH AR2
	
	MOV R1, 51H		;location of first element of array
	MOV R2, 50H		;;no. of elements
	
	FOR:		;loop iterating through the array
		MOV A,@R1
		ANL A,#0FH	;getting last 4 bits of the number by ANDing with 00001111
		SWAP A		;swaping bytes of the number
		MOV LED, A	;putting the number XYZW0000 on the port
		LCALL DELAY	;delay function
		INC R1		;iterative variable
		DJNZ R2, FOR
	
	POP AR2			;restoring registers values
	POP AR1
	POP PSW 
	RET


sumOfSquares:
	USING 0
		
	PUSH PSW ;;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	PUSH AR3
	PUSH AR4
	PUSH B
	
	MOV R2, 50H ;number of elements
	MOV R1, 51H	;location of first element
	MOV R3, 00H ;iterative variable
	MOV R4, 00H ;cumulative sum of squares
	
	FOR2:	;loop for generating sum of squares
		INC R3	;increasing iterative variable
		MOV A, R3	
		MOV B, R3
		MUL AB		;i^2
		ADD A,R4	;adding to the sum
		MOV R4,A	
		MOV @R1,A	;writing sum to i location
		INC R1		;increasing i
		MOV A,R3
		CJNE A,50H,FOR2 ;comparing iterative variable with N
	
	POP B		;restoring register values
	POP AR4
	POP AR3
	POP AR2
	POP AR1
	POP PSW
	
	RET

zeroOut: ;make all the memory locations zero
	USING 0
	PUSH PSW  ;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	
	MOV R2, 50H  ;No. of elements
	MOV R1, 51H  ;location of first element
	
	WRITE:  		 ;functional loop for putting all zeroes in the given range
		MOV @R1, #0
		INC R1
		DJNZ R2, WRITE
	
	POP AR2 ;restoring all values of registers
	POP AR1
	POP PSW
	RET

	
memcpy:			;copying values from array A to array B
	USING 0
	PUSH PSW	;to make sure valuse of registers are stored somewhere
	PUSH AR0
	PUSH AR1
	PUSH AR2
	PUSH AR3
	
	CLR C
	MOV R0, 51H ;location of first element of A
	MOV R1, 52H	;location of first element of B
	MOV R2, 50H	;No. of elements to be copied
	MOV A, R0   ;Subtracting location of first element of A from B
	SUBB A, R1	; to check which of them is greater
				;if B is greater, carry/borrow will be generated
				;if A is greater, carry/borrow won't be genereated
	JC reverse_copy; to take care of overlaping, copying should be done in opposite
					; direction if B is greater than A
		
	forward_copy_loop:	;forward copying when A is greater than B
		MOV A, @R0
		MOV @R1, A
		INC R1
		INC R0
		DJNZ R2, forward_copy_loop
		LJMP ending
		
	reverse_copy:     ;reverse copying when B, is greater than A
					  ;pointer should start from P+N-1 i.e. end of the array for copying 
		MOV A, R2	  
		ADD A, R1	  ;A+N
		MOV R1, A	   	
		MOV A, R2	  ;B+N
		ADD A, R0
		MOV R0, A
		DEC R0		  ;A+N-1
		DEC R1		  ;A+N-1
		reverse_copy_loop: ;similar to forward_copy, but in opposite direction
		MOV A, @R0
		MOV @R1, A
		DEC R1
		DEC R0
		DJNZ R2, reverse_copy_loop
		
		
		
	ending:	;finished copying, restoring registers
	POP AR3
	POP AR2
	POP AR1
	POP AR0
	POP PSW
RET


MAIN:
	MOV SP,#0CFH;-----------------------Initialize STACK POINTER
	MOV 50H,#7;------------------------N memory locations of Array A
	MOV 51H,#60H;------------------------Array A start location
	LCALL zeroOut;----------------------Clear memory
	MOV 50H,#7;------------------------N memory locations of Array B
	MOV 51H,#63H;------------------------Array B start location
	LCALL zeroOut;----------------------Clear memory
	MOV 50H,#7;------------------------N memory locations of Array A
	MOV 51H,#60H;------------------------Array A start location
	LCALL sumOfSquares;-----------------Write at memory location
	MOV 50H,#7;------------------------N elements of Array A to be copied in Array B
	MOV 51H,#60H;------------------------Array A start location
	MOV 52H,#63H;------------------------Array B start location
	LCALL memcpy;-----------------------Copy block of memory to other location
	MOV 50H,#7;------------------------N memory locations of Array B
	MOV 51H,#63H;------------------------Array B start location
	MOV 4FH,#2;------------------------User defined delay value
	LCALL display;----------------------Display the last four bits of elements on LEDs
	here:SJMP here;---------------------WHILE loop(Infinite Loop)
	END
	;------------------------------------END MAIN-------------------------------------------