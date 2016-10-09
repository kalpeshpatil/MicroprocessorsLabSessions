;---------------------------------------------------------------
;TITLE: second smallest
;AUTHOR : KALPESH PATIL (130040019)
;---------------------------------------------------------------


	ORG 00H
	ljmp main
	org 400h
	using 0
secondSmallest:
	push psw		;pushing registers on stack
	push ar0
	push ar1
	push ar5	
	push ar6	
	
	mov r0, #50h ;initiate r0
	mov r1, #51h
	mov r2, #5	 ;total numbers
	mov r5, 50h	 ;initiate first smallest, r5 stores current smallest	
	mov r6, 50h	 ;initiate second smallest, r6 stores second smallest
	
	loop:
		clr c					;remove carry before each iteration
		mov a,@r0
		subb a, r5				
		jc change_smallest		;current number is smaller than smallest
		jz change_smallest		;current number is equal to the smallest
		mov a, @r0				
		subb a, r6				
		jc change_second		;current number is smaller than second smallest
		jz change_second		;current number is equal to the second smallest
		flag1:	inc r0
				djnz r2, loop
		ljmp fin
		
		change_smallest:		;change smallest bu current number
			mov a, r5			;and second smallest by current smallest
			mov r6, a
			mov a, @r0
			mov r5, a
			ljmp flag1
		
		change_second:			;change second smallest by current number
			mov a, @r0
			mov r6, a
			ljmp flag1
			
		fin:					;move second smallest and smallest in desired locations
			mov 55h, r5
			mov 56h, r6
			
		pop ar6					;restoring register values
		pop ar5
		pop ar1
		pop ar0
		pop psw
		
	ret
	
	
	main:
		mov 50h, #5
		mov 51h, #2
		mov 52h, #2
		mov 53h, #1
		mov 54h, #3		
		lcall secondSmallest	;find smallest and second smallest from given array
		stop: sjmp stop
		
end
	
			
			
		
		