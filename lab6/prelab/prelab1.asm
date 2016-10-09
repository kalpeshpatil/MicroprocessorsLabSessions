;Kalpesh Patil (130040019)
;Control Duty cycle
led equ p1.4
using 0
org 00h
ljmp main

org 000Bh
	
	djnz r7, again2ms

	ljmp changeVal

	again2ms:
		mov tl0, #05fh  ;to generate 2ms
		mov th0, #0f0h  ;to generate 2ms
		setb tr0;
	reti
	
	
org 500h
changeVal:
		clr tr0
		clr tf0
		mov tl0, #05fh  ;to generate 2ms
		mov th0, #0f0h  ;to generate 2ms
		jb led, makeLow
			mov A, r6
			mov r7, a
			setb led
			setb tr0
		reti
		makeLow:
			clr c
			mov A, #15
			subb A, r6
			mov r7, A
			clr led
			setb tr0
		reti
		

timerInit:
	setb EA
	setb ET0
	setb ET1
	mov tmod, #01h
	ret

start2ms:
	mov tl0, #05fh  ;to generate 2ms
	mov th0, #0f0h  ;to generate 2ms
	setb tr0
	ret

org 600h
main:
	lcall timerInit
	mov 4fh, #1;
	loo:	mov P1, #0Fh;
			mov a, p1
			anl a, #0fh
			mov r7,a
			mov r6,a
			setb led
			lcall start2ms
			lcall myDelay
			sjmp loo
			
	fin: sjmp fin


myDelay:
	USING 0
	PUSH PSW	;to make sure valuse of registers are stored somewhere 
	PUSH AR1
	PUSH AR2
	PUSH AR3
	PUSH B
	MOV A, 4FH	; D
	MOV B, #20	
	MUL AB		;No. of times 50ms blocks to be executed to generate D sec delay
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

end

	