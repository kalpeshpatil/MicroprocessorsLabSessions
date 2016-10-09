;---------------------------------------------------------------
;TITLE: PRELAB2
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------

	LED EQU P1

	ORG 00H
	LJMP MAIN

	ORG 50H
	
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
	MOV 50H, #4		;No. elements = 4
	MOV 51H, #60H   ;A starting location array A
	MOV 52H, #62H	;B starting location array B
	MOV 60H, #10	;arbitrary values in array A
	MOV 61H, #100   ;--//--
	MOV 62H, #110	;--//--
	MOV 63H, #160	;--//--
	LCALL memcpy	;memcpy function
	SJMP fin		;ending the programme
	fin: SJMP fin
END
	