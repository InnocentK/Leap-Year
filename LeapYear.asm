; File: LeapYear.asm
; CMSC 313 - Spring 2018 - Project 2 - I/O and simple arithmetic
; Innocent Kironji
; wambugu1@umbc.edu
	

section .data 	;Iinitialized data
	msg db "Enter a year:", 0xA
	len equ $ - msg
	ans1 db " is a leap year", 0xA
	a1_len equ $ - ans1
	ans2 db " is not a leap year", 0xA
	a2_len equ $ - ans2

section .bss 	;Uninitialized data
	year resb 4
	eol resb 1

section .text 	;Code Segment
global _start

check_400_multiple:	
	; Testing thousands place
	xor edx, edx
	mov ecx, year
	mov eax, [ecx]
	mov ebx, 2h
	div ebx
	
	; Test the input (if remained is not zero then further checking)
	cmp edx, 0h
jne failed_thousands
	; Testing hundreds place
	xor edx, edx
	mov ecx, year
	mov eax, [ecx + 1]
	mov ebx, 4h
	div ebx
	
	; Test the input (if remainder is not)
	cmp edx, 0h
je leap
jne not_leap
	
failed_thousands:
	; Testing hundreds place
	xor edx, edx
	mov ecx, year
	mov eax, [ecx + 1]
	mov ebx, 4h
	div ebx
	
	; Test the input (only numbers with remainder of 2 are leap years)
	cmp edx, 2h
je leap
jne not_leap	
	
even_tens:
	; When the ten's place has an even number one's place is checked
	xor edx, edx
	mov ecx, year
	mov eax, [ecx + 3]
	mov ebx, 4h
	div ebx
	
	; Test the input (if remainder is not 0 then not leap)
	cmp edx, 0h
jne not_leap
		
; Is only reached once checking all positions of the year 
leap:
	; Display message for a leap year
	mov eax, 4	;system call number (sys_write)
	mov ebx, 1	;first argument: file handle (stdout)
	mov ecx, ans1    ;second argument: pointer to message to write
	mov edx, a1_len	;third argument: message length
	int 0x80	;call kernel and exit
jmp end

_start:

	; Display Prompt for the year
	mov eax, 4	;system call number (sys_write)
	mov ebx, 1	;first argument: file handle (stdout)
	mov ecx, msg    ;second argument: pointer to message to write
	mov edx, len	;third argument: message length
	int 0x80	;call kernel and exit
	
	; Read and store the user input
	mov eax, 3
	mov ebx, 0
	mov ecx, year
	mov edx, 4 	;4 bytes of that information (4 digit number)
	int 80h

	; Output the number entered
	mov byte [eol], 0xA
	mov eax, 4
	mov ebx, 1
	mov ecx, year
	mov edx, 4
	int 80h
	
; Checks for leap year
check_zero:
	; Ones place is checked
	xor edx, edx
	mov ecx, year
	mov eax, [ecx + 3]
	mov ebx, 10h
	div ebx
	cmp edx, 0h
jne no_zero
	; Tens place is checked
	xor edx, edx
	mov ecx, year
	mov eax, [ecx + 2]
	mov ebx, 10h
	div ebx
	cmp edx, 0h
je check_400_multiple

; When year does not end in 00 
no_zero:	
	; Tens place is checked
	xor edx, edx
	mov ecx, year
	mov eax, [ecx + 2]
	mov ebx, 2h
	div ebx
	
	; Test the input
	cmp edx, 0h
je even_tens

odd_tens:	
	; When the ten's place has an odd number one's place is checked
	xor edx, edx
	mov ecx, year
	mov eax, [ecx + 3]
	mov ebx, 4h
	div ebx
	
	; Test the input (only numbers with remainder of 2 are leap years)
	cmp edx, 2h
je leap

not_leap:	
	; Display message for a non-leap year
	mov eax, 4	;system call number (sys_write)
	mov ebx, 1	;first argument: file handle (stdout)
	mov ecx, ans2    ;second argument: pointer to message to write
	mov edx, a2_len	;third argument: message length
	int 0x80	;call kernel and exit
	
; Exit code
end:
	mov eax, 1
	mov ebx, 0
	int 80h