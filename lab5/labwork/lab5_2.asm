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

org 0300h
main:
	lcall init
	backHere:
		mov r4, #00h
		lcall display_msg1
		mov LED, #1Fh    		;switch on LED
		lcall time_counter		;count reaction time
		lcall display_msg2		
		sjmp backHere
	
	finalStop: sjmp finalStop



init:
	push psw

	
	  mov P2,#00h
	  mov P0,#00h
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
	  lcall lcd_sendbytes	;send overflow count, h0 and TL0
	  
	  mov 4FH, #10
	  lcall myDelay

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
	
		 mov a, r4 ; 			;number of times counter overflown
		 lcall ASCIICONV
		 acall lcd_senddata
		 acall delay
		 mov a, b
		 acall lcd_senddata
		 acall delay
		 
         mov a, TH0 ; 			;value of TH0 
		 lcall ASCIICONV
		 acall lcd_senddata
		 acall delay
		 mov a, b
		 acall lcd_senddata
		 acall delay
		 
		 mov a, TL0  ; 			;value of TL0
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


ASCIICONV: MOV R2,A
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
RET

ALPHA2:MOV A,R3
ADD A,#37h          ;ALPHABET TO ASCII
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
		DB "COUNT IS ", 00h

	
	
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
