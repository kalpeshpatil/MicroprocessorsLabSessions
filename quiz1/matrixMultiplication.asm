;---------------------------------------------------------------
;TITLE: matrix multiplication
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------
	ORG 00H
	LJMP MAIN

	ORG 50H
	using 0
matrixMult:
	push psw			;pushing registers on stack
	push ar2
	
	first_term:			;compute first term = x11*y11 + x12*y21
		mov a, 50h
		mov b, 55h
		mul ab			;x11*y11
		mov r2, a
		mov a, 51h
		mov b, 57h
		mul ab			;x12*y21
		add a, r2
		mov 60h, a
		
	
	second_term:		;compute first term = x11*y12 + x12*y22
		mov a, 50h
		mov b, 56h 
		mul ab			;x11*y12
		mov r2, a
		mov a, 51h
		mov b, 58h
		mul ab			;x12*y22
		add a, r2
		mov 61h, a
	
	third_term:			;compute first term = x21*y11 + x22*y21
		mov a, 52h
		mov b, 55h 
		mul ab			;x21*y11
		mov r2, a
		mov a, 53h
		mov b, 57h
		mul ab			;x22*y21
		add a, r2
		mov 62h,a
	
	fourth_term:		;compute first term = x21*y12 + x22*y22
		mov a, 52h
		mov b, 56h 
		mul ab			;x21*y12
		mov r2, a
		mov a, 53h
		mov b, 58h
		mul ab			;x22*y22
		add a, r2
		mov 63h,a
		
	pop ar2				;restoring registers from stack
	pop psw
	
	ret
	
	main:
		mov 50h, #1
		mov 51h, #1
		mov 52h, #1
		mov 53h, #1
		
		mov 55h, #1
		mov 56h, #1
		mov 57h, #1
		mov 58h, #1
	
		lcall matrixMult		;multiply given 2*2 matrices and store result
		
		stop:sjmp stop
	
	end

	
	