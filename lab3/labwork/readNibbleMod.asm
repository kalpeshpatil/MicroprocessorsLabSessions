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


readNibble:
; Routine to read a nibble and confirm from user
; First configure switches as input and LED's as Output.
; To configure port as Output clear it
; To configure port as input, set it.
; Logic to read a 4 bit number (nibble) and get confirmation from user
	push psw
	push AR1
	
	
; Routine to read a nibble and confirm from user
; First configure switches as input and LED's as Output.
; To configure port as Output clear it
; To configure port as input, set it.
; Logic to read a 4 bit number (nibble) and get confirmation from user
loop:
	MOV P1,#0FFH ;turn on all 4 leds (routine is ready to accept input)
	MOV 4FH,#10
	LCALL Delay ;wait for 5 sec during which user can give input through switches
	MOV P1,#0FH;turn off all LEDS
	MOV A, P1;read the input from switches (nibble)
	ANL A, #0FH
	MOV R1, A
	MOV 4EH, R1
	MOV 4FH, #2;wait for one sec
	LCALL Delay
	MOV P1, #00H
	MOV A, R1
	SWAP A
	MOV P1, A;show the read value on LEDs
	MOV 4FH, #10
	LCALL Delay
;wait for 5 sec ( during this time delay User can put all switches to OFF
;position to signal that the read value is correct and routine can proceed to
;next step)
;clear leds
	MOV P1, #0FH;read the input from switches
	MOV A, P1
	
	ANL A, #0FH
	JNZ loop
	POP AR1
	POP PSW
	RET ;if read value <> 0Fh go to loop
; return to caller with previously read nibble in location 4EH (lower 4 bits).
 

MAIN:
	LCALL readNibble
	here: sjmp here

END