org 0
USING 0
ljmp main

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


displayValues:
	push psw
	push AR0
	push AR1
	push AR2
	push AR3
	MOV R1, 51H
	MOV R2, 50H
	looper:
	MOV P1, #0FH
	MOV A, P1
	ANL A, #0FH
	MOV R3, A
	MOV A, R2
	SUBB A, R3
	JC not_valid
	MOV A, 51H
	ADD A, R3
	DEC A
	MOV R0,A
	MOV A, @R0
	MOV P1, A
	MOV 4FH,# 4
	LCALL Delay
	MOV A, @R0
	SWAP A
	MOV P1, A
	LCALL Delay
	sjmp looper
	
	not_valid:
	MOV P1,#00FH
	sjmp fin
	
	fin:
	POP AR3
	POP AR2
	POP AR1
	POP AR0
	POP psw
	RET

sequence:
	USING 0
	PUSH PSW ;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	
	MOV R2, 50H ;number of elements
	MOV R1, 51H	;first element
	
	WRITE:  ;will wirte decreasing sequence N,N-1,N-2...2,1 from first element
	MOV A, R2
	MOV @R1, A
	INC R1
	DJNZ R2, WRITE
	
	POP AR2	;restoring values of registers
	POP AR1
	POP PSW
	RET
	
	MAIN:
	MOV 50H, #10
	MOV 51H, #53H
	LCALL sequence
	
	LCALL displayValues
	
	END
	
	
	
	
	
	
	