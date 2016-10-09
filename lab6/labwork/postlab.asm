; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable
LED      equ P1
using 0
	 
ORG 0000H
ljmp main

ORG 000BH ;ISR address for Timer 0
INC R4 	  ;To keep the count of no. of times timer as overflown
RETI

org 050h
main:
	
	lcall init
	
	backHere:
		
		mov r4, #00h
		lcall display_msg1
		mov 4FH, #10
	  lcall myDelay
		mov LED, #1Fh    		;switch on LED
		lcall time_counter		;count reaction time
		lcall display_msg2
		lcall add16bit
		djnz r5, backHere
		
		mov r5, #5
		lcall calculateAverage
		lcall display_msg3
		
	
	finalStop: sjmp finalStop

calculateAverage:			;divide `6 bit sum by 5
		mov  60h, r1		;dividend's lower byte
		mov  61h, r0		;dividend's higher byte
		mov 62h, r5			;divisor
		
		push psw
		push B 
		push aR2 
		push aR3 
		push aR6 
		push aR7 
		mov a, #0
		CJNE	A,62h,OK

	DIVIDE_BY_ZERO:
		SETB	OV
		ljmp return
		

	OK:	MOV	r1,A     ;r1 low byte of quotient
		MOV	R2,#8	 ;number of times shifting should be done
		MOV	R3,60h
		MOV	R6,61h
		MOV	R7,A

		MOV	A,R6
		MOV	B,R5
		DIV	AB
		MOV	r0,A	;r0 high byte of quotient
		MOV	R6,B

	TIMES_TWO:
		MOV	A,R3
		RLC	A
		MOV	R3,A
		MOV	A,R6
		RLC	A
		MOV	R6,A
		MOV	A,R7
		RLC	A
		MOV	R7,A

	COMPARE:
		CJNE	A,#0,DONE
		MOV	A,R6
		
		CJNE	A,62h,DONE
		CJNE	R3,#0,DONE
	DONE:	CPL	C

	BUILD_QUOTIENT:
		MOV	A,r1
		RLC	A
		MOV	r1,A
		JNB	ACC.0,LOOP

	SUBTRACT:
		MOV	A,R6
		SUBB	A,R5
		MOV	R6,A
		MOV	A,R7
		SUBB	A,#0
		MOV	R7,A

	LOOP:	DJNZ	R2,TIMES_TWO

		MOV	A,R5
		MOV	B,r1
		MUL	AB
		MOV	B,A
		MOV	A,60h
		SUBB	A,B
		MOV	63h,A    ;remainder in 63h
		CLR	OV
	ljmp return

	return:
		pop ar7
		pop ar6
		pop ar3
		pop ar3
		pop b
		pop psw
ret


add16bit:
	clr c
	mov a, r7
	add a, r1
	mov r1, a
	
	mov a,r6
	addc a, r0
	mov r0, a
	
ret

	
	

init:
	push psw

	
	  mov P2,#00h
	  mov P0,#00h
	  mov P1, #00h
      acall delay
	  acall delay
      acall lcd_init      ;initialise LCD
	  acall delay
	  acall delay
	  mov TL0, #00h			
	  mov TH0, #00h
	  setb EA			;enable timers and interrupts
	  setb ET0
	  mov TMOD, #01h	; timer mode1
	  lcall display_msg1
	  mov 4fh, #10
	  lcall myDelay
	  
	  
	  mov r0, #0h   ;higher nibble of sum
	  mov r1, #0h	;higher nibble of sum
	  mov r5, #5    ;total samples
	
	pop psw
ret

display_msg1:
	  lcall lcd_init
	  acall delay
	  acall delay
	  mov a,#81h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov dptr, #my_string1
	  lcall lcd_sendstring
	  mov a,#0C1h		 ;Put cursor on fsecond row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov dptr, #my_string2
	  lcall lcd_sendstring
	  
ret

time_counter:
	  setb EA
	  setb ET0
	  setb tr0
	  mov LED, #1Fh
	  polling: jnb P1.0, polling		;keep polling switch
	  clr tr0							;stop timer
	  mov LED, #0Fh
ret

display_msg2:
	  lcall lcd_init
	  acall delay
	  acall delay
	  mov a,#81h		 ;Put cursor on first row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov dptr, #my_string3
	  lcall lcd_sendstring
	  mov a,#0C1h		 ;Put cursor on second row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov dptr, #my_string4
	  lcall lcd_sendstring
	  acall delay
	  lcall lcd_sendbytes	;send time in ms
	  
	  mov 4FH, #10
	  lcall myDelay

ret

display_msg3:
	lcall lcd_init
	  acall delay
	  acall delay
	  mov a,#81h		 ;Put cursor on first row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov dptr, #my_string3
	  lcall lcd_sendstring
	  mov a,#0C1h		 ;Put cursor on second row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov dptr, #my_string5
	  lcall lcd_sendstring
	  acall delay
	  lcall lcd_sendaverage
ret
	  

lcd_sendaverage:
	push psw
	
	
		
		 mov a, r0		 
		 lcall ASCIICONV
		 acall lcd_senddata
		 acall delay
		 mov a, b
		 acall lcd_senddata
		 acall delay
		 
		 
		 
         mov a, r1			; 			;value of TH0 
		 lcall ASCIICONV
		 acall lcd_senddata
		 acall delay
		 mov a, b
		 acall lcd_senddata
		 acall delay
		 

		 
	    
		 pop psw
ret



			//stay here 

	

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
		 
;-----------------------to send registers values----------------------------
lcd_sendbytes:

	push psw
	
	
		 mov a, r4 ; 	;number of times counter overflown
		 mov b, #33		;to convert to ms
		 mul ab
		 mov r6, b		;higher nibble
		 mov r7, a		;lower nibble
		 
		 mov a, r6		 
		 lcall ASCIICONV
		 acall lcd_senddata
		 acall delay
		 mov a, b
		 acall lcd_senddata
		 acall delay
		 
		 
		 
         mov a, r7			; 			;value of TH0 
		 lcall ASCIICONV
		 acall lcd_senddata
		 acall delay
		 mov a, b
		 acall lcd_senddata
		 acall delay
		 

		 
	    
		 pop psw
ret
                     


;----------------------delay routine-----------------------------------------------------
delay:	 
		push ar0
		push ar1
         mov r0,#1
loop2:	 mov r1,#255
loop1:	 djnz r1, loop1
		 djnz r0,loop2
		 pop ar1
		 pop ar0
		 ret

;--------------------ASCII convertor---------------------------------------------------


ASCIICONV:
push psw
push ar2
push ar3

MOV R2,A
ANL A,#0Fh
MOV R3,A
SUBB A,#09h  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET
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
SUBB A,#09h
JNC ALPHA2 

MOV A,R3			;DIGIT TO ASCII
ADD A,#30h
ljmp retro


ALPHA2:MOV A,R3
ADD A,#37h          ;ALPHABET TO ASCII

retro:
pop ar3
pop ar2
pop psw
RET


;------------- ROM text strings---------------------------------------------------------------
org 1100h
my_string1:
         DB   "PRESS SWITCH SW1", 00H
my_string2:
		 DB   "AS LED GLOWS", 00H
my_string3:
		 DB "REACTION TIME", 00H
my_string4:
		DB "TIME IS ", 00h
my_string5:
		DB "AVRG IS ", 00h
	
	
;------------timer functions-----------------------------------------------
myDelay:
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

end
