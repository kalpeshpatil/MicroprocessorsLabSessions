;---------------------------------------------------------------
;TITLE: PRELAB2
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------

	LED EQU P1.7

	ORG 00H
	LJMP MAIN

	ORG 50H

DELAY:
	USING 0
	PUSH PSW	;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	PUSH AR3
	PUSH B
	MOV A, 4FH	; D
	MOV B, #10	
	MUL AB		;No. of times 50ms blocks to be executed to generate D/2 sec delay
	MOV R3, A
	
	BACK2:					;upper loop running 10*D times
	MOV R2,#200				
	BACK1:					;inner loop of 50ms delay
		MOV R1,#0FFH
		BACK :				;inner to inner loop
			DJNZ R1, BACK
		DJNZ R2, BACK1
	DJNZ R3, BACK2
	
	
	POP B 		;restoring values of the registers
	POP AR3
	POP AR2
	POP AR1
	POP PSW 
	RET

ORG 100H

MAIN:
	MOV 4FH, #1 ;delay time (D/2)
	CLR LED				
	LOOP:		;generating delay in loop
	CLR LED
	LCALL DELAY	;LED off for D/2 sec	
	SETB LED
	LCALL DELAY ;LED on for D/2 sec
	SJMP LOOP

FIN: SJMP FIN; End of programme

END
	