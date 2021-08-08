SECTION .rodata
        read_error:             db 'Something went wrong when reading from stdin', 0xA
        read_error_len:         equ $-read_error

SECTION .text
	global _start

input_one_byte_integer:
	; The function will actually input as many digits as there are in stdin
	; (the input happens until a non-digit character is entered or until input
	; finishes, if the number is too big, an overflow happens silently), convert
	; them to a decimal number, put it to `eax` and return. If no digits were
	; entered, `eax` is set to zero.
	;
	; After the function call there will be one non-digit symbol dropped from
	; standard input (it should be stored at `BYTE [esp - 2]`, when the function
	; returns)


	; Add two bytes to the stack: the top of the stack will be used for reading
	; from `stdin`, the second byte will be used to collect the sum
	push WORD 0

  begin_input:
	mov eax, 3	; The `read` system call
	xor ebx, ebx	; From stdin
	mov ecx, esp	; Read to the end of the stack
	mov edx, 1	; Read only one byte
	int 0x80


	cmp eax, 0
	jl _error	; If return value is less then zero then it's an error
	jz done_with_input	; If read zero symbols, then input is over

	cmp BYTE [esp], '0'
	jl done_with_input	; If inputed symbol is less than `0`, number input is over

	cmp BYTE [esp], '9'
	jg done_with_input	; If inputed symbol is greater than `9`, number input is over


	mov al, [esp + 1]	; Load current sum
	mov bl, 10
	mul bl	; Multiple by `10`, because we're processing a input as a decimal number
	mov bl, [esp]	; Load the read symbol
	sub bl, '0'	; Convert it from symbol code to actual digit
	add al, bl
	mov [esp + 1], al	; Put the new sum back to memory

	jmp begin_input

  done_with_input:

	; Would it be better to do `mov` with `[esp + 1]` as the first operation and then
	; `add` `2` to `esp`? It would take less instructions, but is `esp + 1` evaluation
	; a separate instruction or not? Which of these is easier to read?

	inc esp	; Free the byte used for reading
	movsx eax, BYTE [esp]	; Set the sum as return value
	inc esp
	ret

_start:
	call input_one_byte_integer

	mov ebx, eax	; Use the read integer as the exit code
	mov eax, 1	; Exit
	int 0x80	; Invoke call!

_error:
	mov eax, 4	; The `write` system call
	mov ebx, 2	; To stderr
	mov ecx, read_error
	mov edx, read_error_len
	int 0x80	; Invoke call!

	mov eax, 1	; Exit
	mov ebx, 1	; With code 1
	int 0x80
