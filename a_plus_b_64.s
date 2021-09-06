SECTION .rodata
	digits:			db '0123456789'
        read_error:		db 'Something went wrong when reading from stdin', 0xA
        read_error_len:         equ $-read_error

SECTION .text
	global _start


; Macro adding one byte to stack:
%macro PushByte 1
	dec rsp
	mov BYTE [rsp], %1
%endmacro


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
	; `add` `5` to `rsp`? It would take less instructions, but does evaluation of `rsp + 1`
	; take less CPU cycles?; Which of these is easier to read?

	inc rsp	; Free the byte used for reading
	pop rax		; Set sum as return value, free stack
	ret


print_integer_to_stdout:
	; The function prints the integer value stored in `rax` to stdout in the decimal form.
	; After the number is printed, newline ('\n') is put as the next symbol

	PushByte 0xA	; No matter what we're going to output, we need `'\n'` at the end
	mov rbx, 1	; Counter: number of digits + newline symbol (that's why 1 not 0)
	mov rcx, 10	; In case we do division later, we'll divide by 10. Just set it here.

	; If number is zero, it's a special case
	cmp rax, 0
	jnz nonzero_loop

	; Put output to stack in the reverse order:
	PushByte '0'
	mov rbx, 2	; '0' '\n'
	jmp output_stacked_number_string	; Output

  nonzero_loop:	; Do while `rax` is not zero:
	; `rdx` is considered part of a dividend. Clear it for division
	mov rdx, 0

	div rcx ; Divide by 10 (=`rcx`). Quotient is stored at `rax`, remained is at `rdx`
	; `rdx`, storing the remainder, is equal to a digit which should be printed out;
	; Add `digits` to `rdx` and `push` the corresponding symbol
	add rdx, digits
	; Push one byte symbol to stack (had to do this in 2 operations because of an error)
	movsx rdx, BYTE [rdx]
	PushByte dl
	inc rbx	; Count digit for output

	; If there's something left from the number, repeat
	cmp rax, 0
	jnz nonzero_loop

  output_stacked_number_string:
	mov rax, 1	; The `write` system call
	mov rdi, 1	; To `stdout`
	mov rsi, rsp	; Print the string on top of stack (lucky we are strack grows down)
	mov rdx, rbx	; Output number of symbols counted by counter
	syscall

	add rsp, rdx	; Free stack
	ret


_start:
	call read_integer_from_stdin
	push rax	; Save the first number read
	call read_integer_from_stdin
	pop rbx		; Restore the first number
	add rax, rbx
	call print_integer_to_stdout

	; Exit 0
	mov rax, 60
	mov rdi, 0
	syscall

_error:
	mov rax, 1	; The `write` system call
	mov rdi, 2	; To stderr
	mov rsi, read_error
	mov rdx, read_error_len
	syscall

	mov rax, 60	; Exit
	mov rdi, 1	; With code 1
	syscall
