SECTION .rodata
        read_error:             db 'Something went wrong when reading from stdin', 0xA
        read_error_len:         equ $-read_error

SECTION .text
	global _start

read_integer_from_stdin:
	; The function will read as many digits as there are in stdin
	; (the input happens until a non-digit character is entered or until input
	; finishes; if the number is too big, an overflow happens silently), convert
	; them to a decimal number, put it to `rax` and return. If no digits were
	; entered, `rax` is set to zero.
	;
	; After the function call there will be one non-digit symbol dropped from
	; standard input (it should be stored at `BYTE [rsp - 5]`, when the function
	; returns), unless the input ended (i.e. `read` syscall read 0 symbols)


	; Add 5 bytes to the stack: the top one will be used for reading
	; from `stdin`, the other four will be used to collect the sum
	push 0
	dec rsp

  begin_input:
	mov rax, 0	; The `read` system call
	xor rdi, rdi	; From stdin
	mov rsi, rsp	; Read to the end of the stack
	mov rdx, 1	; Read only one byte
	syscall


	cmp rax, 0
	jl _error	; If return value is less then zero then it's an error
	jz done_with_input	; If read zero symbols, then input is over

	cmp BYTE [rsp], '0'
	jl done_with_input	; If inputed symbol is less than `0`, number input is over

	cmp BYTE [rsp], '9'
	jg done_with_input	; If inputed symbol is greater than `9`, number input is over


	mov rax, [rsp + 1]	; Load current sum
	mov rbx, 10
	mul rbx	; Multiple by `10`, because we're processing a input as a decimal number
	movsx rbx, BYTE [rsp]	; Load the read symbol
	sub rbx, '0'	; Convert it from symbol code to actual digit
	add rax, rbx
	mov [rsp + 1], rax	; Put the new sum back to memory

	jmp begin_input

  done_with_input:

	; Would it be better to do `movsx` with `[rsp + 1]` as the first operation and then
	; `add` `5` to `rsp`? It would take less instructions, but is `rsp + 1` evaluation
	; a separate instruction or not? Which of these is easier to read?

	inc rsp	; Free the byte used for reading
	mov rax, [rsp]	; Set the sum as return value
	add rsp, 8	; Free the rest of the allocated stack
	ret

_start:
	call read_integer_from_stdin

	; Note that your shell will most likely only display an exit code modulo 256
	; (see https://stackoverflow.com/q/179565/11248508)

	mov rdi, rax	; Use the read integer as the exit code
	mov rax, 60	; Exit
	syscall

_error:
	mov rax, 4	; The `write` system call
	mov rdi, 2	; To stderr
	mov rsi, read_error
	mov rdx, read_error_len
	syscall

	mov rax, 60	; Exit
	mov rdi, 1	; With code 1
	syscall
