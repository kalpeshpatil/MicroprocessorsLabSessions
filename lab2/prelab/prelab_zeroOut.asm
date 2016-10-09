;---------------------------------------------------------------
;TITLE: PRELAB2
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------

	LED EQU P1.4

	ORG 00H
	LJMP MAIN

	ORG 50H
	
zeroOut:
	USING 0
	PUSH PSW
	PUSH AR1
	PUSH AR2
	
	MOV R2, 50H
	MOV R1, 51H
	
	WRITE:
	MOV A, R2
	MOV @R1, A
	INC R1
	DJNZ R2, WRITE
	
	POP AR2
	POP AR1
	POP PSW
	RET


MAIN:
	MOV 50H, #16
	MOV 51H, #60H
	LCALL zeroOut
END