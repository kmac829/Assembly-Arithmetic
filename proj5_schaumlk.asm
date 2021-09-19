;Arrays, Addressing, and Stack-Passed Parameters    (proj5_schaumlk.asm)

; Author: Katie Schaumleffle
; Last Modified: 5/21/2021
; OSU email address: schaumlk@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number:  5             Due Date: 5/23/2021
; Description: This program displays the title and programmers name. It then describes
;			what the program will do. It generates a random array (initially set for 200 numbers)
;			within the range LO to HIGH (initially set 10-29), it displays the median of the numbers 
;			in the array, sorts and displays the sorted array in ascending order, displays how many
;			times each number is printed (starting with LO), and then prints a goodbye message.

INCLUDE Irvine32.inc

LO			=		10					;minimum value in array
HI			=		29					;max value in array
ARRAY_SIZE	=		200					
MAX_LINE	=		20	

.data

  arrayCount	DWORD	MAX_LINE	DUP(0)
  randArray		DWORD	ARRAY_SIZE	DUP (?)

  intro1		BYTE	"Welcome to Program #5! Generating, Sorting, and Counting Random Integers, by Katie Schaumleffle." ,0
  instruct1		BYTE	"Please read the following instructions carefully: ",0
  instruct2		BYTE	"   1. This program will generate a list of 200 random numbers in the range [10,29]. ",0
  instruct3		BYTE	"   2. It will then display: " ,0
  instruct4		BYTE	"	   a. The original list." ,0
  instruct5		BYTE	"	   b. The median value.",0
  instruct6		BYTE	"	   c. A sorted list (from smallest number to highest).",0
  instruct7		BYTE	"	   d. The number of instances for each value in the list.",0
  median		BYTE	"The median value of the array: ",0
  unsorted		BYTE	"Your unsorted random numbers: ",0
  sorted		BYTE	"Your sorted random numbers: ",0
  instances		BYTE	"Your list of instances of each generated number, starting with the number of 10's: ",0
  goodbye		BYTE	"Thank you for using this program, I hope you have a wonderful day!",0
  spaces		DWORD	" ",0
  

.code
main PROC
	call		Randomize
	
	;intro and instructions
	push	OFFSET intro1				
	push	OFFSET instruct1			
	push	OFFSET instruct2			
	push	OFFSET instruct3			
	push	OFFSET instruct4			
	push	OFFSET instruct5			
	push	OFFSET instruct6			
	push	OFFSET instruct7			
	call	introduction

	;Fill the array
	push	OFFSET randArray			
	push	ARRAY_SIZE					
	push	HI							
	push	LO							
	call	fillArray

	;Display the unsorted list
	push	MAX_LINE					
	push	OFFSET randArray			
	push	ARRAY_SIZE					
	push	OFFSET spaces				
	push	OFFSET unsorted				
	call	displayList

	;Sort the list
	push	OFFSET randArray			
	push	ARRAY_SIZE					
	call	sortList

	;Calculate the median value
	push	OFFSET median				
	push	OFFSET randArray			
	push	ARRAY_SIZE					
	call	displayMedian

	;Display sorted list
	push	MAX_LINE	
	push	OFFSET randArray
	push	ARRAY_SIZE
	push	OFFSET spaces
	push	OFFSET sorted
	call	displayList

	;Calculate instances each number is printed
	push	OFFSET arrayCount			
	push	LO				
	push	OFFSET randArray		
	push	ARRAY_SIZE		
	call	countList

	;Display instances
	push	ARRAY_SIZE
	push	OFFSET arrayCount		
	push	MAX_LINE				
	push	OFFSET spaces			
	push	OFFSET instances		
	call	displayList
	
	;goodbye
	push	OFFSET goodbye
	call	farewell

main ENDP

Invoke ExitProcess,0	; exit to operating system


;--------------------------------------------------------------------------------------------------------------------------
; Procedure: introduction
;
; Description: Prints the programs intro message, including programmers name, and displays instructions
;
; Preconditions: none
;
; Postconditions: ebp, esp
;
; Receives: intro1, instruct1, instruct2, instruct3, instruct4, instruct5, instruct6, instruct7
;
; Returns: edx: intro messages and instructions
;--------------------------------------------------------------------------------------------------------------------------
introduction PROC
	;set stack frame
	push	ebp
	mov		ebp, esp

	;print intro message
	mov		edx, [ebp +36]
	call	writeString
	call	crlf
	call	crlf

	;print instructions
	mov		edx, [ebp + 32]
	call	writeString
	call	crlf
	mov		edx, [ebp + 28]
	call	writeString
	call	crlf
	mov		edx, [ebp + 24]
	call	writeString
	call	crlf
	mov		edx, [ebp + 20]
	call	writeString
	call	crlf
	mov		edx, [ebp + 16]
	call	writeString
	call	crlf
	mov		edx, [ebp + 12]
	call	writeString
	call	crlf
	mov		edx, [ebp + 8]
	call	writeString
	call	crlf

	pop		ebp
	ret		32

introduction ENDP


;--------------------------------------------------------------------------------------------------------------------------------
; Procedure: fillArray
;
; Description: Fills the array with 200 (ARRAY_SIZE) random numbers
;
; Preconditions: Size of array must be set
;
; Postconditions: ebp, ecx, edi, esp
;
; Receives: randArray, LO, HI, ARRAY_SIZE
;
; Returns: eax: Array filled with random numbers
;--------------------------------------------------------------------------------------------------------------------------------
fillArray PROC
	;set stack frame
	push	ebp
	mov		ebp, esp

	mov		edi, [ebp + 20]			;address of start of array
	mov		ecx, [ebp + 16]			;sets loop

_fillRandom:
	mov		eax, [ebp + 12]
	sub		eax, [ebp + 8]
	inc		eax
	call	RandomRange
	add		eax, [ebp + 8]

	;Add random number into array
	mov		[edi], eax
	add		edi, 4
	loop	_fillRandom

	pop		ebp
	ret		16

fillArray ENDP


;------------------------------------------------------------------------------------------------------------------
; Procedure: displayList
;
; Description: Display the array
;
; Preconditions: The array must be filled with 200 numbers
;
; Postconditions changed: ebp, ecx, esi, esp
;
; Receives: section title, randArray, ARRAY_SIZE, MAX_LINE
;
; Returns: eax & edx: prints array with one space in between each number
;---------------------------------------------------------------------------------------------------------------------
displayList PROC
	;set stack frame 
	push	ebp
	mov		ebp, esp

	;print string stating what's being displayed
	mov		edx, [ebp + 8]
	call	writeString
	call	crlf

	mov		esi, [ebp + 20]
	mov		ecx, [ebp + 16]					;set counter for loop
	mov		ebx, 0

_printLoop:
	mov		eax, [esi]
	call	writeDec
	inc		ebx
	mov		edx, [ebp + 12]
	call	writeString
	add		esi, 4
	cmp		ebx, [ebp + 24]					;checks if new line is needed
	jne		_nextNum
	call	crlf
	mov		ebx, 0

_nextNum:
	loop	_printLoop

	call	crlf
	pop		ebp
	ret		20

displayList ENDP


;------------------------------------------------------------------------------------------------------------------------------------
; Procedure: sortList
;
; Description: Sorts the numbers in the array in ascending order
;
; Preconditions: The array must be filled with 200 numbers
;
; Postconditions changed: eax, ebp, ecx, edx, esi, esp
;
; Receives: randArray, ARRAY_SIZE
;
; Returns: none
;-------------------------------------------------------------------------------------------------------------------------------------
sortList PROC
	;set stack frame
	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp + 8]					;sets loop counter
	dec		ecx
	mov		esi, [ebp + 12]

_outerLoop:
	mov		eax, [esi]
	mov		edx, esi
	push	ecx

_innerLoop:
	mov		eax, [edx]
	mov		ebx, [esi + 4]
	cmp		ebx, eax
	jg		_dontSwap					;if ebx <= eax, don't swap numbers

	;otherwise swap numbers
	add		esi, 4
	push	esi
	push	ecx
	push	edx
	call	exchangeElements				
	sub		esi, 4

_dontSwap:
	add		esi, 4
	loop	_innerLoop
	pop		ecx
	mov		esi, edx
	add		esi, 4
	loop	_outerLoop

	pop		ebp
	ret		8

sortList ENDP


;----------------------------------------------------------------------------------------------------------------------
; Procedure: exchangeElements
;
; Description: Swaps the values in the array 
;
; Preconditions: ebx must be greater than eax
;
; Postconditions: eax, ebp, ecx, edx, esi, esp
;
; Receives: Two values from the array
;
; Returns: None
;---------------------------------------------------------------------------------------------------------------------
exchangeELements PROC
	;set stack frame
	push	ebp
	mov		ebp, esp

	;save registers and variables
	pushad

	mov		ebx, [ebp + 8]
	mov		eax, [ebp + 16]
	mov		edx, eax
	sub		edx, ebx

	;swap numbers in array
	mov		ecx, [ebx]
	mov		esi, ebx
	mov		eax, [eax]
	mov		[esi], eax
	add		esi, edx
	mov		[esi], ecx

	popad
	pop		ebp
	ret		12

exchangeElements ENDP



;------------------------------------------------------------------------------------------------------------------------
; Procedure: displayMedian
;
; Description: Displays the median value 
;
; Preconditions: Array must already be a sorted list
;
; Postconditions: ebx, ebp, ecx, esp
;
; Receives: median, randArray, ARRAY_SIZE
;
; Returns: edx: prints title & eax: prints median value
;-------------------------------------------------------------------------------------------------------------------------
displayMedian PROC
	;set stack frame
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp + 12]
	mov		ecx, [ebp + 8]
	mov		edx, 0

	;Check if even or odd (need to check because constant will be changed when graded- not always even)
	mov		eax, ecx
	mov		ecx, 2
	div		ecx
	cmp		ecx, 0
	je		_evenNum
	jmp		_oddNum

_oddNum:
	mov		ebx, 4
	mul		ebx
	mov		ebx, [eax + esi]
	mov		eax, ebx					;stores median in eax reg
	jmp		_displayMed

_evenNum:
	mov		ebx, 4
	mul		ebx
	mov		ebx, [eax + esi]
	sub		eax, 4						;gives offset of lower index
	mov		eax, [esi + eax]
	add		eax, ebx
	mov		ebx, 2
	div		ebx							;stores med in eax reg

_displayMed:
	mov		edx, [ebp + 16]				;print title
	call	writeString
	call	writeDec					;print median
	call	crlf
	call	crlf

	pop		ebp
	ret		12

displayMedian ENDP



;---------------------------------------------------------------------------------------------------------------------------------
; Procedure: countList
;
; Description: Counts how many times each value is in array 
;
; Preconditions: Array must already be a sorted list
;
; Postconditions: eax, ebx, ecx, edx, edi, esi, esp, ebp
;
; Receives: arrayCount, LO, randArray, ARRAY_SIZE
;
; Returns: None
;----------------------------------------------------------------------------------------------------------------------------------
countList PROC
	;set stack frame
	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp +8]			
	mov		esi, [ebp +12]			
	mov		edi, [ebp + 20]			
	mov		ebx, [ebp + 16]			

_checkNums:
	mov		eax, [esi]
	cmp		ebx, eax				;checks if still 10 (or nth number)
	jne		_nextNum

_count:
	mov		eax, [edi]
	inc		eax
	mov		[edi], eax
	jmp		_continue

_nextNum:
	inc		ebx
	add		edi, 4
	jmp		_count

_continue:
	add		esi, 4
	loop	_checkNums

	pop		ebp
	ret		16

countList	ENDP	


;----------------------------------------------------------------------------------------------------------------------
; Procedure: farewell
;
; Description: Prints goodbye message
;
; Preconditions: none
;
; Postconditions: edx, ebp
;
; Receives: goodbye
;
; Returns: None
;---------------------------------------------------------------------------------------------------------------------------
farewell PROC
	;set stack frame
	push	ebp
	mov		ebp,esp

	call	crlf
	mov		edx, [ebp + 8]
	call	writeString					;print goodbye message
	call	crlf

	pop		ebp
	ret		4

farewell ENDP

END main
