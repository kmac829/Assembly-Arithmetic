;String Primitives and Macros    (proj6_schaumlk.asm)

; Author: Katie Schaumleffle
; Last Modified: 6/6/2021
; OSU email address: schaumlk@oregonstate.edu
; Course number/section:  CS271 Section 400
; Project Number: 6                Due Date: 6/6/2021
; Description: This program uses macros to complete I/O procedures using string primitives. The user is prompted
;				to enter 10 signed integers, the program converts the string of ascii digits to its numeric representation, 
;				it then validates the user's input, displaying an error message if value is not valid. Then,
;				it converts numeric value to a string of ascii digits, and uses the macro mDisplayString to print.
;				Numeric values are stored in an array. mDisplayString is invoked to display the valid numbers, their
;				sum and their average as a string.

INCLUDE Irvine32.inc

; Macro definitions

;-----------------------------------------------------------------------------------------------
; Name: mGetString
;
; Description: Displays a prompt and stores the user's input into memory location. 
; 
; Preconditions: none
;
; Receives:	promptUser & userInput = array address
;			userInput = array address
;			inputLength = array length
;
; Returns:	userInput = generated string address
;			inputLen = length of string
;----------------------------------------------------------------------------------------------
mGetString	MACRO	promptUser, userInput, inputLen
	pushad												; Save registers

	mov				edx, promptUser
	call			WriteString
	mov				ecx, 40
	mov				edx, userInput
	call			ReadString
	mov				inputLen, eax			

	popad												; Restore registers
	
ENDM

;-----------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Description: Prints the string  
; 
; Preconditions: none
;
; Receives:	inputString = string address
;
; Returns: none
;----------------------------------------------------------------------------------------------
mDisplayString	MACRO	inputString
	push			edx		
	
	mov				edx, inputString
	call			WriteString

	pop				edx								
ENDM

; Constants 
INT_COUNT = 10											; Number of integers user will enter

.data

; Variables
intro1				BYTE		"Welcome to Project 6 - String Primitives and Macros! Programmed by Katie Schaumleffle", 13,10,0
ec1					BYTE		"**EC: Number each line of user input and display a running subtotal of the user's valid numbers using WriteVal.**", 13,10,0
instruct1			BYTE		"Please read the following instructions carefully: " ,13, 10, 0 
instruct2			BYTE		"     1. You will be prompted to enter 10 signed integers." ,13,10,0 
instruct3			BYTE		"     2. Each number must fit inside a 32 bit register. " ,13,10,0
instruct4			BYTE		"     3. Once you have entered 10 valid numbers, the program will display a list of integers, their sum, and the average." ,13,10,0
prompt				BYTE		". Please enter a signed number: " ,0
error				BYTE		"I'm sorry, you did not enter a signed number or your number was too big.", 13,10,0
numsEntered			BYTE		"You entered the following numbers: ", 0
comma				BYTE		", ", 0
sumMsg				BYTE		"The sum of these numbers is: ", 0
avgMsg				BYTE		"The rounded average is: ", 0
goodbye				BYTE		"Thank you for playing this fun math game! I hope you have a great day!", 13,10,0

enteredString		BYTE		40 Dup(?)				; User input string
stringLen			DWORD		?						; Length of input string
validNum			SDWORD		?
intArray			SDWORD		INT_COUNT Dup(?)		; Array of valid nums
sum					SDWORD		?
average				SDWORD		?
numInt				DWORD		0						; Initialize number character counter
isNeg				DWORD		0
numString			BYTE		40 Dup(?)				; String of ascii digits 
validCount			DWORD		0						; *EC* Initialize input counter 

.code

main PROC

	; Display the introduction
	push			OFFSET ec1
	push			OFFSET instruct4
	push			OFFSET instruct3
	push			OFFSET instruct2
	push			OFFSET instruct1
	push			OFFSET intro1
	call			introduction
	call			crlf

	;---------------------------------------------------------------------------------
	; Test program in main which uses the ReadVal and WriteVal procedures to:
	; 1. Get 10 valid integers from the user. ReadVal called in main.
	; 2. Store these numeric values in an array.
	; 3. Display the integers, their sum, and average.
	;---------------------------------------------------------------------------------
	
	; Get input from the user 
	mov				edi, OFFSET intArray				; Array to store valid nums
	mov				ecx, INT_COUNT				
	

_input:
	inc				validCount							; Line counter for extra credit

	push			INT_COUNT
	push			stringLen				
	push			OFFSET enteredString	
	push			OFFSET prompt			
	push			OFFSET validNum			
	push			numInt					
	push			OFFSET error			
	push			isNeg				
	push			validCount				
	push			OFFSET numString		
	call			ReadVal

	mov				eax, validNum
	stosd												; Store the validated nums in intArray
	call			crlf
	loop			_input								;Loop through until ecx = 0
	call			crlf
	

	;Display valid nums by looping through the array and calling WriteVal 
	mov				ecx, INT_COUNT
	mov				esi, OFFSET intArray		
	
	mDisplayString OFFSET numsEntered

_display:
	push			INT_COUNT
	push			[esi]						
	push			OFFSET numString
	call			WriteVal							;prints the one number esi is pointing to
	cmp				ecx, 1
	jz				_calcSum							;prevents a comma being printed at the end of the string
	mDisplayString 	OFFSET comma				
	add				esi, 4
	loop			_display							;loop through displaying all 10 values

_calcSum:
	mov				eax, 0
	mov				esi, OFFSET intArray
	mov				ecx, INT_COUNT

_sumL:
	add				eax, [esi]
	add				esi, 4		
	loop			_sumL
	mov				sum, eax							;store the value in sum

	; Display the sum using WriteVal
	call			crlf
	mDisplayString	OFFSET sumMsg

	push			INT_COUNT
	push			sum
	push			OFFSET numString
	call			WriteVal

	; Calculate the avg
	mov				ebx, INT_COUNT
	mov				eax, sum
	cdq
	idiv			ebx
	mov				average, eax

	;Display the average
	call			crlf
	mDisplayString	OFFSET avgMsg
	
	push			INT_COUNT
	push			average
	push			OFFSET numString
	call			WriteVal
	call			crlf
	call			crlf

	; Display the goodbye message
	push			OFFSET goodbye
	call			farewell
	call			crlf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


;----------------------------------------------------------------------------------
; Name: introduction
;
; Description:	Uses the mDisplayString macro to display title, programmers name,
;	extra credit, and instructions to the user. 
;
; Preconditions: ec1 = BYTE array 
;				intro1 = BYTE array 
;				instruct1 = BYTE array 
;				instruct2 = BYTE array 
;				instruct3 = BYTE array
;				instruct4 = BYTE array
;
; Postconditions: none
;
; Receives: [ebp + 28] = address of ec1
;			[ebp + 24] = address of instruct4
;			[ebp + 20] = address of instruct3
;			[ebp + 16] = address of instruct2
;			[ebp + 12] = address of instruct1
;			[ebp + 8] = address of intro1
;			
;
; Returns: none
;---------------------------------------------------------------------------------
introduction PROC
	;Set stack frame
	push			ebp
	mov				ebp, esp				
	
	; Display program title and programmers name
	mDisplayString  [ebp+8]
	call			crlf
	
	; Display the instructions
	mDisplayString 	[ebp + 12]
	mDisplayString	[ebp + 16]
	mDisplayString	[ebp + 20]
	mDisplayString	[ebp + 24]
	call			crlf

	; Display the extra credit option #1
	mDisplayString	[ebp+28]
	call			crlf

	pop				ebp
	ret				24      

introduction ENDP

;----------------------------------------------------------------------------
; Name: ReadVal
;
; Description:	Invokes the mGetString macro to get user input in the form of
;	a string of digits. Converts the string of ascii digits to its numeric
;	value representation, validating the user's input is a valid number.
;	Stores the value in a memory variable, validNum.
;
; Preconditions: INT_COUNT = constant passed to WriteVal		
;				stringLen = length of string entered by user	
;				enteredString = BYTE array to be entered by user
;				prompt = BYTE array
;				validNum = SDWORD 
;				numInt = DWORD, conversion counter initialized to 0 
;				error = BYTE array
;				isNeg = initialized to 0
;				validCount = initialized to 1 passed to WriteVal
;				numString = BYTE array passed to WriteVal
;
; Postconditions: none
;
; Receives: [ebp+44] = INT_COUNT
;			[ebp+40] = stringLen
;			[ebp+36] = address of enteredString
;			[ebp+32] = address of prompt
;			[ebp+28] = address of validNum
;			[ebp+24] = numInt
;			[ebp+20] = address of error
;			[ebp+16] = isNeg
;			[ebp+12] = validCount
;			[ebp+8] =  address of numString
;
; Returns: validNum
;----------------------------------------------------------------------------
ReadVal PROC
	;set stack frame
	push			ebp
	mov				ebp, esp				
	pushad												; Save registers

_getInput:
	; EC#1: number the line of valid inputs
	push			[ebp+44]
	push			[ebp+12]					
	push			[ebp+8]						
	call			WriteVal
	
	; Invoke mGetString macro to get user input in the form of a string of digits.
	mGetString		[ebp+32], [ebp+36], [ebp+40]

	mov				ecx, [ebp+40]						; Set counter to string length
	mov				esi, [ebp+36]				
	mov				edi, [ebp+28]						
	cld											

	;-------------------------------------------------------------------------------------
	; Check the character to see if it's a valid digit.
	; If the first character is a byte, check the sign for ('-' or '+'). 
	;-------------------------------------------------------------------------------------
_checkInt:
	lodsb
	cmp				ecx, 12					
	jae				_error					
	mov				ebx, [ebp+40]
	cmp				ebx, ecx							; Check first character for +/-
	jne				_continue					
	cmp				al, 43								; Positive '+' first character
	jz				_nextChar
	cmp				al, 45								; Negative '-' first character
	jz				_negNum					
	jmp				_continue

_negNum:
	mov				ebx, 1
	mov				[ebp+16], ebx
	jmp				_nextChar

_continue:
	cmp				al, 57
	jg				_error								; If char is greater than 9 (not an int)
	cmp				al, 48
	jl				_error								; If char is less than '0'	(if at this point, then it's not a digit, '+' or '-')

	;----------------------------------------------------------------------------------------
	; Convert string of ascii digits to its numeric representation, validate
	; the user's input is a valid number. Stores this value in validNum during _valid.
	;-------------------------------------------------------------------------------------
	sub				al, 48
	movsx			eax, al
	push			eax
	
	mov				ebx, 10
	mov				eax, [ebp+24]						; Integer conversion counter
	imul			ebx

	pop				ebx
	jo				_error								; Check for overflow
	add				eax, ebx
	mov				[ebp+24], eax
	jo				_error						

_nextChar:
	loop			_checkInt

	mov				ebx, 1
	cmp				[ebp+16], ebx						; Check for negative integer
	jne				_valid
	neg				eax

_valid:
	mov				[edi], eax							; Store validated number in validNum
	jmp				_done
	
_error:
	mDisplayString	[ebp+20]							; Print error message
	mov				ebx, 0						
	mov				[ebp+24], ebx						; Reset integer conversion counter
	mov				[ebp+16], ebx						; Reset isNeg
	jmp				_getInput

_done:
	popad												
	pop				ebp
	ret				40

ReadVal	ENDP

;----------------------------------------------------------------------------
; Name: WriteVal
;
; Description:	Converts a numeric value to a string of ascii digits.
;	Invokes the mDisplayString macro to print the ascii representation of the
;	value to the output.
;
; Preconditions: numString = BYTE array to be displayed
;
; Postconditions: none
;
; Receives: [ebp+16] = INT_COUNT constant
;			[ebp+12] = int to be converted to string of ascii digits
;			[ebp+8] = address of numString
;
; Returns: numString
;----------------------------------------------------------------------------
WriteVal PROC
	;set stack frame
	push			ebp
	mov				ebp, esp				
	pushad												

	mov				ecx, 0
	mov				edi, [ebp+8]						
	mov				esi, [ebp+12]							
	mov				eax, esi
	cmp				eax, 0							
	jge				_again

	push			eax									; add '-' to the string for neg nums
	mov				al, 45	
	stosb

	pop				eax
	neg				eax									; get absolute value

	;-------------------------------------------------------------------------------
	; Converts the num to a string of ascii digits. Keeps track
	; of the number of values pushed to the stack.  Pops from the
	; stack and adds the values to the string array.
	;-------------------------------------------------------------------------------
_again:
	mov				ebx, [ebp+16]						; Divide by INT_COUNT 
	cdq
	idiv			ebx

	add				edx, 48
	push			edx									; Push the remainder to the stack
	inc				ecx									

	cmp				eax, 0
	jz				_reverse
	jmp				_again

_reverse:
	pop				eax									
	stosb												; Store char in string array
	loop			_reverse

	mov				al, 0								; Null terminator
	stosb		

_done:
	mDisplayString [ebp+8]

	popad												; Restore registers
	pop				ebp
	ret				12

WriteVal ENDP

;----------------------------------------------------------------------------
; Name: farewell
;
; Description: Uses mDisplayString macro to display a goodbye message.
;
; Preconditions: goodbye = BYTE array 
;
; Postconditions:	none
;
; Receives: [ebp+8] = address of goodbye
;
; Returns: none
;----------------------------------------------------------------------------
farewell PROC
	;set the stack frame
	push			ebp
	mov				ebp, esp				

	mDisplayString 	[ebp+8]								;Print goobye message

	pop				ebp						
	ret				4      

farewell ENDP

END main