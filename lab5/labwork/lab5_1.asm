;lab5_1
;Kalpesh Patil (130040019)

org 00h
ljmp main

org 00Bh
	clr tf0
	clr tr0
	reti

using 0

timer_delay:
	push psw
	push ar0
	push ar1
	push ar2
	
	clr c
	mov r0, #91h
	mov r1, #92h
	mov a, 91h
	mov r3,a
	mov a, #0
	subb a, r3
	mov r3, a
	mov a, 92h
	mov r4, a
	mov a,#0
	subb a, r4
	mov r4, a
	
	mov TH0, r4
	mov TL0, r3
	
	pop ar2
	pop ar1
	pop ar0
	pop psw

ret

timer_init:

	setb EA
	setb ET0
	mov TMOD, #01h
	ret


start_timer:
	setb tr0
	ret

org 500h
main:
	;mov a , #01h
	mov 91h , #015
	mov 92h,  #00
	lcall timer_init
	lcall timer_delay
	lcall start_timer
    
	fin: sjmp fin

end