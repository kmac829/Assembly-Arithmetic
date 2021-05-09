;Project 3: Data Validation, Looping, and Constants     (proj3_schaumlk.asm)

; Author: Katie Schaumleffle
; Last Modified:5/1/2021
; OSU email address: schaumlk@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 3                Due Date: 5/2/2021
; Description: This program prompts the user to enter a negative integer between [-200,-100] and [-50,-1] inclusively. 
;				The program will continue until a positive integer is entered. It will then display the 
;				total number of valid numbers entered, the sum, the smallest number, largest number, and 
;				the rounded average.

INCLUDE Irvine32.inc

max1 =	-100
min1 =	-200
max2 =	-1
min2 =	-50

.data


userNum		SDWORD	?		;int to be entered by user
countVar	SDWORD	0		;counter variable that keeps track of number of valid inputs
sum			SDWORD	?		;variable to hold sum
avg			SDWORD	0		;variable to hold rounded avg
numLine		SDWORD	1		;line number for EC
max			SDWORD	-201
min			SDWORD	0
remainder	SDWORD	0

userName	BYTE	50	DUP(0)
intro_1		BYTE	"Hello, this is Program #3: Data Validation, Looping, and Constants by Katie Schaumleffle!", 0
intro_2		BYTE	"What is your name? " ,0
intro_3		BYTE	"Hello, ",0
intro_4		BYTE	". I hope you enjoy this program!",0
ec_1		BYTE	"**EC Option #1: Number the lines during user input.", 0
instruct_1	BYTE	"Please read the following instructions carefully:", 0
instruct_2	BYTE	"1. You will be prompted to enter a negative integer. Please make sure you enter within the range [-200, -100] or [-50,-1].", 0
instruct_3	BYTE	"2. As long as the numbers you enter are within these ranges, you will continue to be prompted to enter a number.", 0
instruct_4	BYTE	"3. As soon as you enter a non-negative number, the program will calculate the following: ",0
instruct_5	BYTE	"         a. The number of valid numbers that were entered. ",0
instruct_6	BYTE	"         b. The sum of all valid numbers. ",0
instruct_7	BYTE	"         c. The largest valid number. ",0
instruct_8	BYTE	"         d. The smallest valid number. " ,0
instruct_9	BYTE	"         e. The rounded average of all valid numbers. " ,0
prompt_1	BYTE	". Please enter a number: ", 0
notValid	BYTE	"I'm sorry, that is not a valid number. Please try again." ,0
noValids	BYTE	"I'm sorry, no valid numbers were entered.",0
validNums_1	BYTE	"You entered ",0
validNums_2	BYTE	" valid numbers.",0
validSums	BYTE	"The sum of your valid numbers is: ",0
maxNum_1	BYTE	"The largest number entered is: ",0
minNum_1	BYTE	"The smallest number you entered is: ",0
roundAvg	BYTE	"The rounded average of your valid numbers is: ",0
goodbye_1	BYTE	"Thank you for playing this program, ",0
goodbye_2	BYTE	". It was very nice to meet you! Goodbye!",0

.code
main PROC

;--------------------------------------------------------------------------------------------------------------------------------------------
;	Introduces the programmer (Katie) to the user, displays the EC option,
;	gets the users name, and greets the user.
;--------------------------------------------------------------------------------------------------------------------------------------------

;Display students name and program title
	mov		EDX, OFFSET intro_1	
	call	WriteString
	call	Crlf
	call	Crlf

;Display EC option
	mov		EDX, OFFSET ec_1
	call	WriteString
	call	crlf
	call	crlf

;Get users name
	mov		EDX, OFFSET intro_2
	call	WriteString
	mov		EDX, OFFSET	userName
	mov		ECX, sizeof userName
	call	ReadString

;Greet user
	mov		EDX, OFFSET intro_3
	call	WriteString
	mov		EDX, OFFSET userName
	call	WriteString
	mov		EDX, OFFSET intro_4
	call	WriteString
	call	Crlf
	call	Crlf

;--------------------------------------------------------------------------------------------------------------------------------------------
;	This section of code displays the instructions for the user. Each instruction
;	is placed on a new line in order to make it more readable for the user.
;--------------------------------------------------------------------------------------------------------------------------------------------

_instructions:
	;Give instructions to user
	mov		EDX, OFFSET instruct_1
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_2
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_3
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_4
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_5
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_6
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_7
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_8
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET instruct_9
	call	WriteString
	call	Crlf
	call	Crlf


;--------------------------------------------------------------------------------------------------------------------------------------------
;	This section of code is where we prompt the user for a number 
;	(based on paramaters listed in the instructions) and read it in. This is also 
;	the section where we check to see if the number entered by the user is valid or not.
;--------------------------------------------------------------------------------------------------------------------------------------------
_enterNum:
	mov		EAX, numLine
	call	writeDec
	mov		EDX, OFFSET prompt_1
	call	WriteString
	call	readInt							;Prompts user for number and reads it in.
	mov		userNum, EAX
	call	crlf

	;Validate value in range between -200 & -100
	mov		eax, min1						 ;eax = -200
	cmp		eax, userNum						
	jg		_range2							;if > -200, go to next range check
	mov		eax, userNum
	cmp		eax, max1
	jg		_range2							;if <-100, go to next check
	jmp		_sum

;Check if number is between other -50 & -1
_range2:								
	mov		eax, min2						;eax = -50
	cmp		eax, userNum
	jg		_outOfRange						
	mov		eax, userNum			
	cmp		eax, max2
	jg		_outOfRange						
	jmp		_sum
	loop	_enterNum						;loops back to have user input another number

_outOfRange:
	mov		eax, userNum
	test	eax, eax						;used to set flag
	jns		_calcAverage
	mov		edx, OFFSET notValid
	call	writeString
	call	crlf
	call	crlf
	loop	_enterNum						;loop back to prompt user for another number


;--------------------------------------------------------------------------------------------------------------------------------------------
;	If the user number is valid, we come to this section, where we do all of 
;	our calculations. The _sum is where we increment the number line and count variable
;	as well as add to our sum. Then we check for the smallest and largest number,
;	and then we calculate the rounded average of the total valid inputs.
;--------------------------------------------------------------------------------------------------------------------------------------------
_sum:
	inc		numLine							;increments the line number if user input is valid
	inc		countVar						;increments the number of valid inputs
	mov		ebx, userNum
	add		sum, ebx						;add new user num to accumulated total

_maxCheck:
	mov		edx, usernum
	cmp		edx, max
	jng		_minCheck						;if max < usernum
	mov		ebx, userNum
	mov		max, ebx

_minCheck:
	mov		edx, userNum
	cmp		edx, min
	jnl		_enterNum						;if min > usernum
	mov		ebx, userNum
	mov		min, ebx
	jmp		_enterNum

_calcAverage:
	;If no valid inputs, we don't want to divide by 0 
	mov		ebx, 0
	cmp		ebx, countVar
	je		_none

	;if there are valid inputs, calculate rounded average
	mov		eax, sum
	cdq										;sign extend for calculation
	idiv	countVar
	mov		avg, eax						;quotient saved in eax
	mov		remainder, edx					;remainder saved to edx, updates to remainder variable
	neg		remainder
	mov		ebx, 2
	imul	ebx, remainder
	cmp		ebx, countVar
	jng		_none
	dec     avg								;round avg


;--------------------------------------------------------------------------------------------------------------------------------------------
;	This section is where we display all of our results. The first, _none section is used when
;	there are no valid inputs. Otherwise _results is where we display the number of valid inputs,
;	the sum, the largest number, smallest number, and the rounded average. Lastly, we display 
;	our goodbye message.
;--------------------------------------------------------------------------------------------------------------------------------------------
_none:
	mov		ebx, 0
	cmp		ebx, countVar
	jne		_results						;if countVar != 0, move on to results
	call	crlf
	mov		edx, OFFSET noValids
	call	writeString						;display no valid numbers entered message
	call	crlf
	call	crlf
	jmp		_goodbye

_results:
	;display valid numbers entered
	call	crlf
	mov		edx, OFFSET validNums_1
	call	writeString
	mov		eax, countVar
	call	writeDec
	mov		edx, OFFSET validNums_2
	call	writeString
	call	crlf

	;display sum
	mov		edx, OFFSET validSums
	call	writeString
	mov		eax, sum
	call	writeInt
	call	crlf

	;display largest number
	mov		edx, OFFSET maxNum_1
	call	writeString
	mov		eax, max
	call	writeInt
	call	crlf

	;display smallest number
	mov		edx, OFFSET minNum_1
	call	writeString
	mov		eax, min
	call	writeInt
	call	crlf

	;display rounded average
	mov		edx, OFFSET roundAvg
	call	writeString
	mov		eax, avg
	call	writeInt
	call	crlf
	call	crlf

_goodbye:
	mov		edx, OFFSET goodbye_1
	call	WriteString
	mov		edx, OFFSET userName			;displays user's name in goodbye message.
	call	WriteString
	mov		edx, OFFSET goodbye_2
	call	WriteString
	call	CrLf


	exit	; exit to operating system
main ENDP


END main
