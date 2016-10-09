;Kalpesh Patil (130040019)
;Control Duty cycle

; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable1
	
led equ p1
using 0
org 00h
ljmp main

org 00bh
	lcall loadT0
	setb tr0
	djnz r1, check2
	cjne r2, #0, check1
	
	readTo:						;read T1 in R4R5
		MOV A,TH1
		MOV R4,TL1
		CJNE A,TH1,readTo
		MOV R5,TH1
	LCALL loadT1				;load timer 1
	LCALL switchRead
	LCALL printLCD
	
	mov r2, #2
	check1:
		dec r2
		mov r1, #250
	
	check2:
		cjne r0, #0, check3
		mov a, r7
		mov r6, a
		mov r0, #15
	


	check3: 
		dec r0
		cjne r6,#0d,check4
		mov led, #0fh
		clr p3.7
		clr p1.7	;1.7
	reti
	check4:
		dec r6
		MOV LED, #0FH
		SETB P3.7
		SETB P1.7	;1.7
	reti
	
		

	
	
	

loadT0:
	mov tl0, #05fh  ;to generate 2ms
	mov th0, #0f0h
	ret
	
switchRead:
	mov P1, #0fh
	mov a, P1
	anl a, #0Fh
	mov r7, a	;value of swithc in r7
	mov r6, a   ;
	ret

loadT1:

	MOV TL1, #00h
	MOV TH1, #00h
	ret
	
init:
	setb EA
	setb ET0
	setb ET1
	mov led, #0fh
	clr p1.7
	clr p3.7
	mov tmod, #51h; counter 1 in mode 1 and timer 0 in mode 1
	mov r0, #15	; for 30ms delay
	mov r1, #250; for 0.5 sec delay
	mov r2, #1  ; for 0.5*2 = 1 sec delay
	mov r3, #0  ; counter for 2ms block
	mov r4, #0
	mov r5, #0
	mov tl0, #0ffh  ;to generate 2ms
	mov th0, #0ffh  ;to generate 2ms
	mov tl1, #00h
	mov th1, #00h
	setb tr1
	acall printLCD
	ret


;---------------lcd print ----------------------------------------
printLCD:
	mov P2, #0
	mov P0, #0
	acall delay
	acall delay
	acall lcd_init
	acall delay
	acall delay
	mov a, #80h    ;cursor on first line coloumn zero
	acall lcd_command
	acall delay
    mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	acall lcd_sendstring	   ;call text strings sending routine
	acall delay
	mov a,#0C0h		  ;Put cursor on second row, starting from 1 column
	acall lcd_command
	acall delay
	acall printRPM    ;function to print rpm
	acall delay   
	ret
	
;------------------fucnction to print rpm---------------------------
printRPM:
	mov a, #0c0h     ;put cursor on second row, starting from 1
	acall lcd_command
	acall delay
	mov a, r7		;send input	
	acall ASCIICONV
	acall lcd_senddata
	mov a, b		;send input
	acall lcd_senddata
	//multiply TH1TL1 value by 2 to get RPM (by calculation)
	clr c
	MOV A,R4
	ADD A,R4
	MOV R4,A 
	
	MOV A,R5  
	ADDC A,R5
	MOV R5,A 
	
	
	MOV A,R5 
	LCALL ASCIICONV
	acall lcd_senddata
	MOV A,B
	acall lcd_senddata
	
	
	MOV A,R4
	LCALL ASCIICONV
	acall lcd_senddata
	MOV A,B
	acall lcd_senddata
	
	ret
	

;--------------------------------------ASCII convert---------------------------
ASCIICONV:
	PUSH ar2
	PUSH ar3
	MOV R2,A
	ANL A,#0Fh
	MOV R3,A
	CLR C
	SUBB A,#0Ah  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET
	JNC ALPHA

	MOV A,R3
	ADD A,#30h   ;ADD 30H TO CONV HEX TO ASCII
	MOV B,A
	JMP NEXT

	ALPHA: MOV A,R3  ;ADD 37H TO CONVERT ALPHABET TO ASCII
	ADD A,#37h
	MOV B,A

	NEXT:MOV A,R2
	ANL A,#0F0h          ;CHECK HIGHER NIBBLE IS DIGIT OR ALPHABET
	SWAP A
	MOV R3,A
	CLR C
	SUBB A,#0Ah
	JNC ALPHA2 

	MOV A,R3			;DIGIT TO ASCII
	ADD A,#30h
	POP 3
	POP 2
	RET

	ALPHA2:MOV A,R3
	ADD A,#37h          ;ALPHABET TO ASCII
	POP ar3
	POP ar2
RET

;---------------------------lCD subroutines---------------------------
;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
         clr   a                 ;clear Accumulator for any previous data
         movc  a,@a+dptr         ;load the first character in accumulator
         jz    exit              ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   dptr              ;increment data pointer
         sjmp  LCD_sendstring    ;jump back to send the next character
exit:
         ret                     ;End of routine
		 
;----------------------delay routine-----------------------------------------------------
delay:	 
	push ar0
	push ar1
    mov r0,#1
	loop2:	
		mov r1,#255
	loop1:	 
	djnz r1, loop1
	djnz r0,loop2
	pop ar1
	pop ar0
	ret
		 



org 600h
main:
	lcall init
	lcall switchRead
	setb tr0
	stop: sjmp stop



org 1200h
my_string1:
         DB   "IN RPM", 00H
			 
end