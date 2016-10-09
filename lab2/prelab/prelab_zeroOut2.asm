;---------------------------------------------------------------
;TITLE: PRELAB2
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------

	LED EQU P1.4 ;Port 1.4 is used for LED display

	ORG 00H
	LJMP MAIN

	ORG 50H
	
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

MAIN:
	MOV 50H, #16  	;no. of elements
	MOV 51H, #53H	;location of first element
	MOV 53H, #20H	;arbitrary values put in different locations
	MOV 54H, #43H	;-----//-----
	MOV 62H, #32H	;-----//-----
	MOV 63H, #45H	;an extra value kept at the location beyond the range which should not be zeroed
	LCALL zeroOut
	SJMP fin
	fin: SJMP fin
END