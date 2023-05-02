TITLE Project 6   (Proj6_whittlea.asm)

; Author: Abigail Whittle
; Last Modified: 3/18/23
; OSU email address: whittlea@oregonstate.edu
; Course number/section:   CS271 Section 406
; Project Number:                 Due Date: 3/19/23
; Description: This file gathers input from the user as a string, verfies it is a signed integer and stores it in a sdword that can fit in a 32 bit register, then adds it to an array,
; Once the array is filled with 10 valid characters, the program prints the numbers out, then calculates the average and sum and displays it as a string (by converting the sdword back into a string)

INCLUDE Irvine32.inc

; (insert macro definitions here)

; ---------------------------------------------------------------------------------
; Name: mGetString
; 
; This macro displays a prompt and reads a string from the user, storing it in a buffer.
;
; Preconditions:
;		inputs are of the correct type
;     
; Postconditions: None
;
; Receives:
;		prompt        - string containing the prompt to display
;		inputAddress  - buffer to store the input string
;		stringLength  - maximum length of the input string
;		bytesRead     - buffer to store the length of the input string
;
; Returns:
;		inputAddress  - string containing the user input
;		bytesRead     - size of the string
; ---------------------------------------------------------------------------------

mGetString MACRO prompt, inputAddress, stringLength, bytesRead
    push edx
    push ecx
    push eax

	; Display prompt
    mov edx, prompt
    call WriteString

	; Read string
    mov edx, inputAddress
    mov ecx, stringLength
    call ReadString
    mov bytesRead, eax							; Write length of the string to bytesRead

    pop eax
    pop ecx
    pop edx
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
; 
; This macro displays a null-terminated string to the console.
;
; Preconditions:
;		input is a valid string
;
; Postconditions: None.
;
; Receives:
;		stringAddress  - string to be displayed
;
; Returns: None.
; ---------------------------------------------------------------------------------

mDisplayString MACRO stringAddress
    push edx

	; Display string
    mov edx, stringAddress
    call WriteString

    pop edx
ENDM

; (insert constant definitions here)

MINUS = 45
MAX = 50
COUNT = 10

.data

; (insert variable definitions here)

progTitle		byte "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",0
progAuthor		byte "Written by: Abigail Whittle",0
prompt1			byte "Please provide 10 signed decimal integers.",0
prompt2			byte "Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the ",0
prompt3			byte "integers, their sum, and their average value.",0
mainPrompt		byte "Please enter a signed number: ",0
tryAgainPrompt	byte "Please try again: ",0
endMsg			byte "You entered the following numbers:",0
comma			byte ", ",0
sumMsg			byte "The sum of theses numbers is: ",0
avgMsg			byte "The truncated average is: ",0
errorMsg        byte "ERROR: You did not enter a signed number or your number was too big",0
bye				byte "Thanks for playing!",0

; Inital input array
inputStr		byte (MAX+1) dup(0)
inputLen		dword ?

; Required for conversion from ASCII to SDWORD
num 			sdword 0
temp			sdword 0
mult			sdword 1
digit 			dword 0

; Array of valid integers
inputNum		sdword COUNT dup(0)

; Required math operations
sum 			sdword 0
avg 			sdword 0

; Required for conversion from SDWORD to ASCII
outputStr		byte (COUNT+2) dup(0)

valid dword 0

.code
main PROC

	; (insert executable instructions here)

	; Call introduction
	push offset prompt3
    push offset prompt2
    push offset prompt1
    push offset progAuthor
    push offset progTitle
    call introduction

	; Loop until 10 valid numbers have been entered
	mov ecx, COUNT
	getInput:
		; Call ReadVal
		push offset digit
		push offset mult
		push offset temp 
		push offset num
		push offset valid
		push offset errorMsg
		push inputLen							; Passed by value for macro
	    push offset inputLen
		push MAX								; Passed by value because its a constant
		push offset inputStr

		; Check if the last call was valid, if it wasn't proceed as normal
		cmp valid, 1
		je invalidCall

		push offset mainPrompt
		call ReadVal

		jmp store

		; If the last call was invalid, display "try again" message and make valid 0 again
		invalidCall:
			mov valid, 0

			push offset tryAgainPrompt
			call ReadVal

		; Store num into the array
		store:
			cmp valid, 1
			je getInput

			; If valid, update array and location
			mov eax, COUNT						; current location = COUNT - ecx
			sub eax, ecx
			mov ebx, offset inputNum
			mov edx, 4

			mul edx								; currCount * 4
			add ebx, eax						; ebx = [ebx + currCount * 4]

			; Add num to the input number array
			mov eax, num
			mov [ebx], eax

			dec ecx
			jnz getInput

	; Get the required results after array is filled
	getResults:
		; Get the sum
		push offset sum
		push COUNT								; Passed by value because its a constant
		push offset inputNum
		call getSum

		; Get the avg
		push offset avg
		push sum								; Passed by value because avg proc should not change it
		push COUNT								; Passed by value because its a constant
		call getAvg

		; Display the entered numbers message
        call crlf
        mDisplayString offset endMsg
        call crlf

        ; Iterate through array and output the numbers
        mov ecx, COUNT
        loopArray:
            ; Find current element
            mov eax, COUNT                      ; current location = COUNT - ecx
            sub eax, ecx
            mov ebx, offset inputNum
            mov edx, 4

            mul edx                             ; currCount * 4
            add ebx, eax                        ; ebx = [ebx + currCount * 4]

			; Call WriteVal for every element in the array
			push MINUS
            push (COUNT + 1)
            push offset outputStr
            ; Push current element to WriteVal
            push [ebx]
            call WriteVal

            ; If last element, do not write comma
            cmp ecx, 1
            je displayResults

            ; Else display comma
            mDisplayString offset comma
            loop loopArray

        ; Display sum and avg
        displayResults:
            call crlf
            ; Display sum (using writeval)
            mDisplayString offset sumMsg
			push MINUS
            push (COUNT + 1)
            push offset outputStr
            push sum
            call WriteVal
            call crlf

            ; Display avg (using writeval)
            mDisplayString offset avgMsg
			push MINUS
            push (COUNT + 1)
            push offset outputStr
            push avg
            call WriteVal

	; Call bye
    push offset bye
    call goodbye

	Invoke ExitProcess,0						; exit to operating system
main ENDP

; (insert additional procedures here)

; ---------------------------------------------------------------------------------
; Name: introduction
; 
; This procedure displays an introduction message with a title, author, and instructions
; for the user.
;
; Preconditions: None.
;
; Postconditions: The procedure modifies the console output by displaying the
; introduction message.
;
; Receives: 
;		[ebp+8]  - string containing the title
;		[ebp+12] - string containing the author
;		[ebp+16] - string containing instruction 1
;		[ebp+20] - string containing instruction 2
;		[ebp+24] - string containing instruction 3
;
; Returns: None.
; ---------------------------------------------------------------------------------

introduction PROC
    push ebp
    mov ebp, esp

    mDisplayString [ebp+8]						; Display title
	call crlf
    mDisplayString [ebp+12]						; Display author
    call crlf
	call crlf
    mDisplayString [ebp+16]						; Display instructions 1
	call crlf
    mDisplayString [ebp+20]						; Display instructions 2
	call crlf
    mDisplayString [ebp+24]						; Display instructions 3
    call crlf
	call crlf

    mov esp, ebp
    pop ebp
    ret 20
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
; 
; This procedure reads and validates user input, converting a string to a signed integer.
;
; Preconditions:
;		inputNum is not filled
;
; Postconditions: 
;		inputStr has been reveresed, validated and converted to a signed number
;
; Receives:
;		[ebp+8]  - string containing the prompt to display
;		[ebp+12] - buffer to store the input string
;		[ebp+16] - maximum length of the input string
;		[ebp+20] - length of the input string
;		[ebp+24] - address of the length of the input string
;		[ebp+28] - string containing the error message to display
;		[ebp+32] - flag to store whether the input is valid or not
;		[ebp+36] - buffer to store the converted integer
;		[ebp+40] - buffer to store the temporary integer value
;		[ebp+44] - buffer to store the multiplier (1 or -1)
;		[ebp+48] - buffer to store the current digit being read
;
; Returns:
;		num   - the converted integer
;		valid - flag to set if input is invalid
; ---------------------------------------------------------------------------------

ReadVal PROC
	push ebp
	mov ebp, esp
	pushad 

	; Get the string
	mGetString [ebp+8], [ebp+12], [ebp+16], [ebp+24]

	evaluate: 
		; Store updated value of inputLen
		mov eax, [ebp+20]						; String length
		mov ebx, [ebp+24]						; String length address
		mov [eax], ebx

		; If the string length is larger than 11, throw error
		mov eax, 11 
		cmp eax, ebx
		jl error

		; If the string length is 0, throw error
		cmp ebx, 0
		je error

		; If the length is 1 validate it
		cmp ebx, 1
		je validate

		; Reverse the string
		reverse:
			pushad
			mov esi, [ebp+12]					; String address
			mov ecx, ebx						; String length address

			; Calculate the last character in the string
			lea edi, [esi+ecx-1]

			; Divide length by 2 (how many swaps there will be)
			mov eax, ecx 
			mov ebx, 2
			mov edx, 0
			div ebx
			mov ecx, eax						; ECX = number of swaps

			swap:
				mov al, [esi]					; index i
				mov ah, [edi]					; index j

				; Swap the elements
				xchg al, ah

				mov [esi], al					; store [j] at i
				mov [edi], ah					; store [i] at j

				; Move the pointter
				inc esi
				dec edi

				loop swap
			popad

		; Validate the values in the string
		validate:
			pushad
			mov ecx, ebx						; String length address
			mov esi, [ebp+12]					; String address

			; Set num = 0
			mov eax, [ebp+36]
			mov ebx, 0
			mov [eax], ebx

			; Set temp = 0
			mov eax, [ebp+40]
			mov ebx, 0
			mov [eax], ebx

			; Set mult = 1
			mov eax, [ebp+44]
			mov ebx, 1
			mov [eax], ebx

			;Set digit = 0
			mov eax, [ebp+48]
			mov ebx, 0
			mov [eax], ebx

			; If length 1, jump to first char check
			cmp ecx, 1
			je firstChar

			dec ecx								; Do not read last character
			mov edx, 0							; Flag to check if last character was read

			; Check if the character is a digit
			check:
				lodsb
				numberCheck:					; Label to jump if first char is not - or +
					sub al, 48

					; If char is < 0, throw error
					cmp al, 0
					jl error

					; If char is > 9, throw error
					cmp al, 9
					jg error

					; Move the char to temp
					movzx eax, al				; Zero extend al into eax
					mov ebx, [ebp+40]
					mov [ebx], eax

					multiply:
						pushad
						; Mov num, digit, and temp into registers
						mov edi, [ebp+36]
						mov ecx, [ebp+48]

						; Mov the values of the numbers into the same registers
						mov edi, [edi]
						mov ecx, [ecx]

						; If digits = 0, skip the 10^(digits) loop
						cmp ecx, 0
						je tempMult

						mov esi, 1
						PowerLoop:
							imul esi, 10

							dec ecx
							jnz PowerLoop		; Loop until digits = 0

						imul eax, esi			; Multiply temp and 10^(digits)

						tempMult:
							add eax, edi

							jo error			; If overflow, throw error

							; Store result in num
							mov edi, [ebp+36]	
							mov [edi], eax

							popad

					; Increase the number of digits
					mov eax, [ebp+48]
					mov ebx, [eax]
					inc ebx
					mov [eax], ebx

					loop check

			; If the first char was checked, jump to finish
			cmp edx, 1
			je done

			; Set multiplier
			firstChar:
				lodsb							; Get char

				; If char = '+', jump to positive label
				cmp al, 43
				je done

				; If char = '-', jump to negative label
				cmp al, 45
				je negative

				mov ecx, 1						; Prevent loop error
				mov edx, 1						; Mark firstChar as checked
				jmp numberCheck

				negative:
					; Set multiplier to -1
					mov eax, [ebp+44]			; Multiplier
					mov ebx, -1
					mov [eax], ebx

					; Multiply num by -1
					mov eax, ebx
					mov ebx, [ebp+36]			; Num
					mov ebx, [ebx]
					imul ebx

					; Store result in num
					mov ebx, [ebp+36]			; Num
					mov [ebx], eax

					jmp done

	; If the input is not valid, change the flag
	error:

		mDisplayString [ebp+28]					; Display error message
		call crlf

		; Change flag
		mov eax, [ebp+32]
		mov ebx, 1
		mov [eax], ebx

	done:
		popad 
		mov esp, ebp
		pop ebp
		ret 44
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: getSum
; 
; This procedure calculates the sum of all the elements in an array of integers.
;
; Preconditions: 
;		inputNum has the correct number of elements
; 
; Postconditions: None
; 
; Receives: 
;		[ebp+8]   - buffer storing the input number array
;		[ebp+12]  - length of the input array
;		[ebp+16]  - buffer to store the sum
;
; Returns:
;		sum - the sum of all the elements in the input array
; ---------------------------------------------------------------------------------

getSum PROC
	push ebp
	mov ebp, esp
	pushad

	; Move parameters to registers
	mov ebx, [ebp+8]							; number array address
	mov ecx, [ebp+12]							; length of array
	mov eax, [ebp+16]							; sum
	mov eax, [eax]								; dereference the sum

	mov esi, ebx								; Initialize element 1 of the array

	; Add every element in the array to sum
	sumLoop:
		; Load the current element
		mov edi, [esi]

		; Add current element to sum and increase the array pointer
		add eax, edi
		add esi, 4

		loop sumLoop

	; Store result in sum
	mov edx, [ebp+16]
	mov [edx], eax

	done:
		popad
		mov esp, ebp
		pop ebp
		ret 12
getSum ENDP

; ---------------------------------------------------------------------------------
; Name: getAvg
; 
; This procedure calculates the average of an array of integers by dividing the sum
; of the array elements by the length of the array.
;
; Preconditions:
;		sum contains the correct summation of all the elements in the input array
; 
; Postconditions: None
; 
; Receives:
;		[ebp+8]  - length of the input array
;		[ebp+12] - buffer storing the sum
;		[ebp+16] - buffer to store the average
; 
; Returns:
;		avg - the average of all the elements in the input array
; ---------------------------------------------------------------------------------

getAvg PROC
	push ebp
	mov ebp, esp
	pushad

	; Move parameters to registers
	mov ebx, [ebp+8]							; lenght of array
	mov eax, [ebp+12]							; sum
	mov ecx, [ebp+16]							; avg

	; Divide sum by array length
	cdq											; edx sign extends eax
	idiv ebx

	; Store the result in sum
	mov [ecx], eax

	done:
		popad
		mov esp, ebp
		pop ebp
		ret 12
getAvg ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; This procedure takes a signed integer and converts it to a string representation.
; It also clears the provided buffer and reverses the string representation if needed.
;
; Preconditions:
;		[ebp+8] is a valid sdword
;
; Postconditions: None
;
; Receives:
;		[ebp+8]  - signed integer (sdword) to convert to a string
;		[ebp+12] - buffer to store the output string
;		[ebp+16] - size of the buffer to store the output string
;		[ebp+20] - minus sign (ASCII value) to use in the output string
;
; Returns:
;		Output string has been filled with the string representation of the input number.
; ---------------------------------------------------------------------------------

WriteVal PROC
    push ebp
    mov ebp, esp
    pushad

    ; Move the parameters into registers
    mov ebx, [ebp+12]							; string address
    mov ecx, [ebp+16]							; string size

    mov esi, ebx
    ; Clear the entire string
    clear:
        mov eax, 0
        mov [esi], eax
        add esi, 4
        dec ecx
        jnz clear ; Loop until the entirety of the output string is cleared

    mov eax, [ebp+8]							; sdword
    mov ebx, 0									; reversed number
    mov ecx, 0									; number of digits

    ; Check if the number is negative
    cmp eax, 0
    jge reverse

    ; If negative, negate the number and add a - sign to the string
    neg eax
    mov ebx, [ebp+12]							; string address
    mov dl, [ebp+20]							; minus sign
    mov [ebx], dl
    inc ebx										; Increment the string address by 1 byte

	mov ebx, 0

	; Reverse the string
    reverse:
        ; Set up for division
		cdq
        mov edx, 0
        mov esi, 10

        idiv esi								; Divide the number by 10
        imul ebx, esi							; Multiply the reversed number by 10
        add ebx, edx							; Add the remainder to the reversed number

        inc ecx									; Increase the number of digits

        cmp eax, 0
        jnz reverse								; Loop until the entire number has been parsed

	; Restore the string address
    mov eax, ebx
    mov ebx, [ebp+12]
    mov dl, [ebx]
    cmp dl, [ebp+20]							; Check if minus sign was added
    jne positive								; Jump to positive if no minus sign was added

    inc ebx										; Otherwise, increment the string address by 1 byte

	; Set up for conversion
    positive:
	mov edx, 0
    mov esi, 10

	; Convert the reversed number into a string
    convert:
		cdq
        idiv esi								; Divide the reversed number by 10
        add dl, 48								; Add the ascii character 0 to the remainder
        
		; Store the number in the in the string and increment the address
		mov [ebx], dl
        inc ebx

		; If the entire number has been parsed, jump to done
        dec ecx
        jz done
		; Other loop until the whole number has been parsed through
        mov edx, 0
        jmp convert

    done:
		; Note: I do not need to add a null terminal because the output string already has one that cannot be overwritten due to the length I gave it
		; Display the new string
        mDisplayString [ebp+12]

        popad
        mov esp, ebp
        pop ebp
        ret 16
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: goodbye
; 
; This procedure displays a goodbye message to the user.
;
; Preconditions: None
;
; Postconditions: The procedure modifies the console output by displaying the goodbye
; message.
;
; Receives:
;		[ebp+8]  - string containing the goodbye message
;
; Returns: None
; ---------------------------------------------------------------------------------

goodbye PROC
    push ebp
    mov ebp, esp

	call crlf
    call crlf
    mDisplayString [ebp+8]						; Display goodbye string
	call crlf

    mov esp, ebp
    pop ebp
    ret 4
goodbye ENDP

END main