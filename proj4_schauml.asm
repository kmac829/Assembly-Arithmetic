;Nested Loops and Procedures     (proj4_schauml.asm)

; Author: Katie Schaumleffle
; Last Modified: 5/15/2021
; OSU email address: schaumlk@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  4               Due Date:5/16/2021
; Description: This program calculates prime numbers. We first prompt the user to enter a number,
;			   in the range [1, 200], and the program will generate a list of 
;			   all prime numbers, up to the number entered by the user. 

INCLUDE Irvine32.inc

UPPER_LIMIT	=	200
LOWER_LIMIT =	1

.data

userNum			DWORD	?
pFlag			DWORD	0
printedPrimes	DWORD	0
currentNum		DWORD	1					
maxLine			DWORD	10
numCmp			DWORD	2					;divisor initialized to 2
userName		BYTE	50	DUP(0)

intro_1			BYTE	"Hello, this is Program #4: Nested Loops and Procedures by Katie Schaumleffle!", 0
intro_2			BYTE	"What is your name? " ,0
intro_3			BYTE	"Hello, ",0
intro_4			BYTE	". I hope you enjoy this program!",0
EC1				BYTE	"**EC Option 1: Align the first digit of each number on a row with the row above." ,0
instruct_1		BYTE	"Please read the following instructions carefully:", 0
instruct_2		BYTE	"1. You will be prompted to enter the number of primes that you would like to see.", 0
instruct_3		BYTE	"2. You may enter any number from 1-200.", 0
instruct_4		BYTE	"3. As long as the number is within this range, the computer will output that many primes. ",0
prompt1			BYTE	"Please enter the number of primes to display [1...200]: ",0
invalid			BYTE	"I'm sorry, that number is out range. Please try again!",0
goodbye			BYTE	"Thank you for using this Prime's calculator! I hope you enjoyed it!",0
	
.code
main PROC

	call	introduction
	call	instruction
	call	getUserData
	call	showPrimes
	call	farewell

main ENDP


;--------------------------------------------------------------------------------------------------------------------------------------------
;	Name: introduction
;
;	Description: Introduces the programmer (Katie) to the user, displays the EC option,
;				gets the users name, and greets the user.
;
;	Preconditions: None
;
;	Postconditions: ecx
;
;	Receives: intro_1, intro_2, EC1, userName, sizeOf userName
;
;	Returns: edx- Prints the program name, programmers name, EC option, and greets the user.
;--------------------------------------------------------------------------------------------------------------------------------------------

introduction PROC
	
	;Display program and programmers name
	mov		edx, OFFSET intro_1
	call	writeString
	call	crlf
	call	crlf

	;Display EC #1
	mov		edx, OFFSET EC1
	call	writestring
	call	crlf
	call	crlf

	;Gets users name
	mov		edx, OFFSET intro_2
	call	writeString
	mov		edx, OFFSET	userName
	mov		ecx, sizeof userName
	call	ReadString

	;Greets user
	mov		edx, OFFSET intro_3
	call	writeString
	mov		edx, OFFSET userName
	call	writeString
	mov		edx, OFFSET intro_4
	call	writeString
	call	crlf
	call	crlf
	ret

introduction ENDP


;--------------------------------------------------------------------------------------------------------------------------------------------
;	Name: instruction
;
;	Description: Displays instructions for the user. Each isntruction placed on
;				a new line to make the program more readable.
;
;	Preconditions: None
;
;	Postconditions: None (edx in returns)
;
;	Receives: instruct_1, instruct_2, instruct_3, instruct_4
;
;	Returns: Prints the instructions
;--------------------------------------------------------------------------------------------------------------------------------------------

instruction PROC

	mov		edx, OFFSET instruct_1
	call	writeString
	call	crlf
	mov		edx, OFFSET instruct_2
	call	writeString
	call	crlf
	mov		edx, OFFSET instruct_3
	call	writeString
	call	crlf
	mov		edx, OFFSET instruct_4
	call	writeString
	call	crlf
	call	crlf
	ret

instruction ENDP


;--------------------------------------------------------------------------------------------------------------------------------------------
;	Name: getUserData
;
;	Description: Prompt the user for the number of primes to display and stores 
;				it in the variable userNum. If number is out of range, prompt again.
;
;	Preconditions: None
;
;	Postconditions: edx
;
;	Receives: prompt_1
;
;	Returns: eax- valid
;--------------------------------------------------------------------------------------------------------------------------------------------

getUserData PROC

	mov		edx, OFFSET prompt1
	call	writeString
	call	readInt
	mov		userNum, eax					;store users input into variable 
	call	validate
	ret

getUserData ENDP


;--------------------------------------------------------------------------------------------------------------------------------------------
;	Name: validate
;
;	Description: Check to see if the number entered by the user is in range [1,200]
;				or not. If the number is not in range, then we print an error message 
;				and prompt user for another number.
;
;	Preconditions: userNum is type DWORD
;
;	Postconditions: eax, edx
;
;	Receives: userNum, UPPER_LIMIT, LOWER_LIMIT, invalid
;
;	Returns: If nunmber is valid or not
;--------------------------------------------------------------------------------------------------------------------------------------------

validate PROC
	mov		eax, userNum
	cmp		eax, UPPER_LIMIT
	jg		_error
	cmp		eax, LOWER_LIMIT
	jl		_error

	;if the number makes it here, then it's in range
	jmp		_valid

;If not in range, print error message
_error:
	mov		edx, OFFSET invalid
	call	writeString
	call	crlf
	call	crlf
	call	getUserData						;Since not in range, go back and get new num from user
	ret

_valid:
	ret

validate ENDP


;--------------------------------------------------------------------------------------------------------------------------------------------
;	Name: showPrimes
;
;	Description: Print all of the primes up to the number entered by the user. 
;				We do this by implementing a loop, initialized to userNum, and 
;				decrement each time a number is printed. Only print 10 numbers per line. 
;
;	Preconditions: userNum is valid and we have printed < userNum values of primes
;
;	Postconditions: ebx, edx, ecx, al
;
;	Receives: userNum, currentNum, numCmp, pFlag, printedPrimes
;
;	Returns: eax, prints the prime number and loops through until we reach the amount of
;			primes that match userNum
;--------------------------------------------------------------------------------------------------------------------------------------------

showPrimes PROC
	mov		ecx, userNum					;initialize loop to userNum

_primeLoop:
	inc		currentNum					
	mov		numCmp, 2						; set divisor to 2 to check if prime
	mov		eax, currentNum				
	mov		ebx, currentNum				
	cmp		ebx, 2						
	je		_print							; print first prime (2)
	call	isPrime						
	cmp		pFlag, 1				    
	je		_print							; if pFlag was set to 1 in isPrimes, then print 
	jmp		_primeLoop						; else, go back and check the next number, without decrementing ecx						

_print:	
	call	WriteDec					
	mov		al, 9							; ASCII 9 adds tab to align nums
	call	WriteChar					
	mov		pFlag, 0						; reset to 0 so we can check for primes
	inc		printedPrimes
	cmp		printedPrimes, 10				; if we have 10 numbers on a line, start new line
	je		_newLine
	loop	_primeLoop						; decrement ecx
	call	CrLF
	ret								

_newLine:
	call	crlf
	mov		printedPrimes, 0
	loop	_primeLoop
	ret

showPrimes ENDP



;--------------------------------------------------------------------------------------------------------------------------------------------
;	Name: isPrime
;
;	Description: Calculate to see if currentNum is prime or not. 
;
;	Preconditions: default bool value is set to 0
;
;	Postconditions: eax, ebx, edx
;
;	Receives: currentNum, numCmp, pFlag
;
;	Returns: pFlag = boolean value; 1 is prime, 0 is not prime
;--------------------------------------------------------------------------------------------------------------------------------------------

isPrime PROC
_checkPrime:
	mov		edx, 0						
	mov		eax, currentNum				
	mov		ebx, numCmp					
	div		ebx							
	cmp		edx, 0							; if remaineder is 0 then it's not prime
	je		_notPrime					
	inc		numCmp							; if remainder found increment to divide next number
	mov		ebx, numCmp					
	cmp		ebx, currentNum					; continue as long as dividend doesn't equal divisor			
	jl		_checkPrime					
	mov		eax, currentNum					
	jmp		_yesPrime						; if we get here, then a prime is found

_notPrime:
	mov		pFlag, 0						; set flag for not prime
	ret

_yesPrime:
	mov		pFlag, 1						;  set flag for prime
	ret

isPrime ENDP


;--------------------------------------------------------------------------------------------------------------------------------------------
;	Name: farewell
;
;	Description: Say goodbye and end the program.
;
;	Preconditions: None
;
;	Postconditions: None
;
;	Receives: goodbye
;
;	Returns: edx- Prints the goodbye message.
;--------------------------------------------------------------------------------------------------------------------------------------------

farewell PROC
	call	crlf
	mov		edx, OFFSET goodbye
	call	writeString
	call	crlf
	call	crlf
	
farewell ENDP


Invoke ExitProcess,0						; exit to operating system
END main