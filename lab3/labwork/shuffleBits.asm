ORG 00H
	LJMP MAIN
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
		
		MERGER:			;TO MERGE TWO NIBBLES INTO 1 BYTE
		PUSH PSW
		PUSH AR0
		PUSH AR1
			MOV 4EH,#00H
			LCALL READNIBBLE
			MOV R0,4EH			
			LCALL READNIBBLE
			MOV A,4EH			
			SWAP A
			ORL A,R0
			MOV 4FH,A
		POP AR1
		POP AR0
		POP PSW
		RET
		
		READVALUES:
		PUSH PSW
		PUSH AR0
		PUSH AR1
		MOV R0,50H
		MOV R1,51H
		LOOP7:
		LCALL MERGER
		MOV @R1,4FH
		INC R1
		DJNZ R0,LOOP7
		POP AR1
		POP AR0
		POP PSW
		RET	

DISPLAY:
PUSH PSW
PUSH AR0
PUSH AR1
        MOV R0,50H                        ;k
        MOV P1,#0FH

        upper_loop:        MOV P1,#0FH
                        MOV 4FH,#04H
                        LCALL DELAY                
                        MOV R1,51H                ;pointer
                        MOV A,P1
                        MOV R4,A		;
                        CLR C
                        SUBB A,R0		;check if index is higher than K 
                        JNC STOP		;switch off all if index is greater
                        MOV A,R4
                        ADD A,R1
                        MOV R1,A
                        MOV A,@R1
                        MOV P1,#0FH
                        ANL A,#0F0H
                        MOV P1,A
                        MOV 4FH,#04H
                        LCALL DELAY
                        MOV A,@R1		;d
                        ANL A,#0FH
                        SWAP A
                        MOV P1,A
                        MOV 4FH,#04H
                        LCALL DELAY
                SJMP upper_loop
				POP AR1
				POP AR0
				POP PSW

        STOP: MOV P1,#0FH
                  SJMP STOP
				  
				  SHUFFLEBITS:
				  PUSH PSW
				  PUSH AR0
				  PUSH AR1 		;push pop operations
				  PUSH AR2		
				  MOV R0,51H	;
				  MOV R1,52H
				  MOV R2,50H
				  DEC R2		;K-1 XOR operations in loop, last done separately
				  form_loop:
				  MOV A,@R0
				  INC R0
				  XRL A,@R0
				  MOV @R1,A
				  INC R1
				  DJNZ R2,form_loop
				  MOV A,@R0
				  MOV R0,51H
				  XRL A,@R0		;individual XOR operation last
				  MOV@R1,A
					POP AR2
					POP AR1
					POP AR0
					POP PSW
					RET
		
ORG 200H
MAIN:
MOV SP,#0CFH;-----------------------Initialize STACK POINTER
MOV 50H,#03H;------------------------Set value of K
MOV 51H,#60H;------------------------Array A start location
MOV 4FH,#00H;------------------------Clear location 4FH
LCALL READVALUES
MOV 50H,#03H;------------------------Value of K
MOV 51H,#60H;------------------------Array A start location
MOV 52H,#70H;------------------------Array B start location
LCALL SHUFFLEBITS
MOV 50H,#03H;------------------------Value of K
MOV 51H,#70H;------------------------Array B start Location
LCALL DISPLAY;----------------Display the last four bits of elements on LEDs
here:SJMP here;---------------------WHILE loop(Infinite Loop)
END