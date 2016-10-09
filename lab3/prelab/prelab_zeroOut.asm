
; Setup code at reset vector of 8051 to jump to our main task 
org 0
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
;=========================================


main:
;=========================================
	; Port initialisation
	MOV P1,#0Fh			; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read

	; read nibble from port
	LCALL readNibble		; read nibble using subroutine
	
	SWAP A					;P1.4 to P1.7 = P1.0 to P1.3 (read from readNibble)
	MOV P1, A				;
	
	MOV 50H,A				; save nibble read in location 50H
	
	MOV 51H, #53H	;location of first element
	MOV 53H, #20H	;arbitrary values put in different locations
	MOV 54H, #43H	;-----//-----
	MOV 62H, #32H	;-----//-----
	
	LCALL zeroOut

	; end of job
	STOP: JMP STOP		

;=========================================
; End of program file
END




