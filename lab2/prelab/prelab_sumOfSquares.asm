;---------------------------------------------------------------
;TITLE: PRELAB2
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------

	LED EQU P1

	ORG 00H
	LJMP MAIN

	ORG 50H

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
	
MAIN:
	MOV 50H, #7  ;number of elements
	MOV 51H, #60H ;first element
	LCALL sumOfSquares
	
	
END
	
	
	