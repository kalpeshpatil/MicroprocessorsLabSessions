; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start
using 0
org 100h
start:
      mov P2,#00h
	  mov P1,#00h
	  ;initial delay for lcd power up

;here1:setb p1.0
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1


	  acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
	  mov a,#81h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1   ;"ABPSW"
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	lcall lcd_sendABPSW ;function o send ABPSW
	  mov a,#0C1h		  ;Put cursor on second row,3 column
	  acall lcd_command
	  acall delay
	 mov   dptr,#my_string2 ;"R012"
	 acall lcd_sendstring
	 acall delay
	 
	 ;acall lcd_sendstring
	 
	 
	lcall lcd_sendregisters ; function to send registers data
	;  acall lcd_sendname
	acall delay
	mov 4Fh, #10
	lcall myDelay
	
	acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
	  mov a,#81h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string3   ;"R345"
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	lcall lcd_sendreg2 ;function o send ABPSW
	  mov a,#0C1h		  ;Put cursor on second row,3 column
	  acall lcd_command
	  acall delay
	 mov   dptr,#my_string4 ;"R67SP"
	 acall lcd_sendstring
	 acall delay
	 
	 
	 acall delay
	 acall delay
	 
	lcall lcd_sendreg3 ; function to send registers data
	;  acall lcd_sendname
	
	

here: sjmp here				//stay here 

;--------------------------myDelay-----------------------------------------------
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

lcd_sendregisters:
	push psw
		push ar5
		 clr a
		 mov R0,#0A4h			;arbitray value in R0 
		 mov a,R0          
		 lcall ASCIICONV		;convert numbers to ASCII
		 acall lcd_senddata
		 mov a,b				
         acall lcd_senddata
		 mov a,#32				
		acall lcd_senddata
		
		mov R1,#46h    			; arbitrary value in R1
		 mov a,R1        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 mov a,#32
		acall lcd_senddata
		
		mov R2,#54h				; arbitrary value in R2
			 mov a,R2        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 pop ar5
		 pop psw
		 ret
                  

;-----------------------to sendreg3----------------------------
lcd_sendreg3:
	push psw
		push ar5
		 clr a
		 mov R6,#0B4h			;arbitray value in R0 
		 mov a,R6          
		 lcall ASCIICONV		;convert numbers to ASCII
		 acall lcd_senddata
		 mov a,b				
         acall lcd_senddata
		 mov a,#32				
		acall lcd_senddata
		
		mov R7,#86h    			; arbitrary value in R1
		 mov a,R1        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 mov a,#32
		acall lcd_senddata
		
		;mov R2,#54h				; arbitrary value in R2
			 mov a,sp        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 pop ar5
		 pop psw
		 ret
;--------------------------send ABPSW------------------------------
lcd_sendabpsw:
		push psw
		push ar3
		push ar4
		push ar5     
		mov r3,a
		mov r4,b
		mov r5, psw
		
		mov a, #10h
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 mov a,#32
		acall lcd_senddata
		
		mov b, #34h
		 mov a,b
        lcall ASCIICONV
	      acall lcd_senddata
		 mov a,b
		 acall lcd_senddata
		 mov a,#32
		acall lcd_senddata
		
		mov a, r5
		lcall ASCIICONV
         acall lcd_senddata
		 mov a,b
		acall lcd_senddata
		 pop ar5
		 pop ar4
		 pop ar3
		 pop psw
         ret 


	
;------------------------------------sendreg2-----------------------------------

lcd_sendreg2:
	push psw
		push ar5
		 clr a
		 mov R3,#054h			;arbitray value in R0 
		 mov a,R3          
		 lcall ASCIICONV		;convert numbers to ASCII
		 acall lcd_senddata
		 mov a,b				
         acall lcd_senddata
		 mov a,#32				
		acall lcd_senddata
		
		mov R4,#65h    			; arbitrary value in R1
		 mov a,R4        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 mov a,#32
		acall lcd_senddata
		
		mov R5,#44h				; arbitrary value in R2
			 mov a,R5        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 pop ar5
		 pop psw
		 ret
                     

;----------------------delay routine-----------------------------------------------------
delay:	 
         mov r0,#1
loop2:	 mov r1,#255
loop1:	 djnz r1, loop1
		 djnz r0,loop2
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
         DB   "ABPSW=", 00H
my_string3:
		 DB   "R345=", 00H
my_string2:
		 DB "R012=", 00H
my_string4:
		DB "R67SP=", 00H
end

