;---------------------------------------------------------------
;TITLE: PRELAB2
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------

	LED EQU P1

	ORG 00H
	LJMP MAIN

	ORG 50H
	
sequence:
	USING 0
	PUSH PSW ;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	
	MOV R2, 0H ;number of elements
	MOV R1, 51H	;first element
	
	WRITE:  ;will wirte decreasing sequence N,N-1,N-2...2,1 from first element
	INC R2
	MOV A, R2
	MOV @R1, A
	INC R1
	MOV A, R2
	CJNE A, 50H, WRITE
	
	POP AR2	;restoring values of registers
	POP AR1
	POP PSW
	RET

DELAY:
	USING 0
	PUSH PSW ;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	PUSH AR3
	PUSH B
	MOV A, 4FH	;location of D
	MOV B, #10	
	MUL AB;      No. of times 50ms blocks to be executed to generate D/2 sec delay
	MOV R3, A
	
	BACK2:					;upper loop running 10*D times
	MOV R2,#200            
	BACK1:					;inner loop of 50ms delay
		MOV R1,#0FFH
		BACK :				;inner to inner loop
			DJNZ R1, BACK
		DJNZ R2, BACK1
	DJNZ R3, BACK2
	
	
	POP B 		;restoring all values
	POP AR3
	POP AR2
	POP AR1
	POP PSW 
	RET
	
	


Display:
	USING 0
	PUSH PSW	;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	
	MOV R1, 51H ;location of first element of array
	MOV R2, 50H	;no. of elements
	
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


MAIN:
	MOV LED, #0H
	MOV 50H, #5			;No of elements
	MOV 51H, #60H		;location of first element of array
	MOV 4FH, #2			;delay seconds
	LCALL sequence      ;sequence genearator for displaying on LED
	LCALL Display		;displaying on LED
	fin: SJMP fin
	
END