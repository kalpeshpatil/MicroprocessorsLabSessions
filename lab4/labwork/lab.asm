; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable
using 0
	 
ORG 0000H
ljmp starter

starter:		;initialize pointers for generating sequence	
push psw
push ar0
push ar1
push ar2
mov r2, #16
mov r0, #60h
mov r1, #24

seq:			;sequence generator (x, x+4, x+8....)
mov a, r1
mov @r0, a
mov r1, a
add a,#4
mov r1, a
inc r0

djnz r2, seq

ljmp start


org 200h
start:
      mov P2,#00h
	  mov P1,#00h
	  ;initial delay for lcd power up

;here1:setb p1.0
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1


bigLoop:
	  acall lcd_init      ;initialise LCD
	  acall delay
	  acall delay
	  acall delay
	  
	  mov P1, #0Fh		;reading from switches
	  mov a, p1
	  anl a, #0Fh
	  swap a
	  mov r6, a
	  
	lcall lcd_sendbytes
	  mov 4Fh, #10
	  lcall myDelay		;delay of 5 sec
	  mov a, r6
	  add a, #8
	  lcall lcd_sendbytes
	  lcall myDelay
	  ljmp bigLoop
	 	

here: sjmp bigloop			//stay here 


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
	push ar0
	push ar1
	push ar2
	push ar5
	push ar7
	mov r7,#4
	mov r0,a
	mov r5,a
	
	 mov a,#81h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	 
	mov a, r5
	mov r0,a
	looper:		
		
		mov a, r5
		 mov r0, a
		 mov a,@R0        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 mov a,#32
		acall lcd_senddata
		
		
		inc r5
		djnz r7, looper
		
	mov r7,#4	
	 mov a,#0C1h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	
	looper2:		
		mov a, r5
		mov r0, a
		
		 mov a,@R0        
		 lcall ASCIICONV
		 acall lcd_senddata
		 mov a,b
         acall lcd_senddata
		 mov a,#32
		acall lcd_senddata
		
		inc r5
		djnz r7, looper2
		
		pop ar7
		 pop ar5
		 pop ar2
		 pop ar1
		 pop ar0
		 pop psw
		 ret
                     
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
		 DB   ",", 00H
my_string2:
		 DB "R012=", 00H
my_string2a:
		DB " = "
end
	
;----------timer functions-------------------------------------------------------------


