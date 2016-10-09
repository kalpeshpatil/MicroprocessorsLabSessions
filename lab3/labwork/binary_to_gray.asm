
; Setup code at reset vector of 8051 to jump to our main task 
org 0
USING 0
ljmp main		


;=========================================
readNibble:
;=========================================
; Routine to read in Port lines P1.3 - P1.0 as a sngle nibble
; Returns the nibble in lower 4 bits of the register A
;
; Ensure that the internal port latches are set high already 
; prior to calling this routine
;=========================================

	MOV A,P1			; read port lines P1.3 - P1.0 where slide switches are connected
	ANL A,#0FH			; retain lower nibble and mask off upper one

	RET					; Return to caller with nibble in A

	  

		
;=========================================

binaryToGray:
	PUSH PSW
	PUSH AR1
	CLR C
	LCALL readNibble
	;MOV A, 52H
	MOV R1, A			;R1 = 0000abcd
	RRC A				;A =  00000abc
	XRL A,R1				;A =  1111a(abc^bcd)
	ANL A,#0FH			;A =  0000a(abc^bcd)
	SWAP A
	MOV P1, A
	POP AR1
	POP PSW
	RET

;============================================

main:
	; Port initialisation
	MOV P1,#0Fh			; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
	loop:
		LCALL binaryToGray
	LJMP main
	fin: sjmp fin
end