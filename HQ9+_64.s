; This is an HQ9+ interpreter. Read more about the language at wikipedia.
; Usage: <interpreter_executable> <source_file>

; This code uses x86 general-purpose register as follows:
; rax - For system calls
; rbx - Unused
; rcx - Unused
; rdx - For system calls
; rsi - For system calls
; rdi - For system calls and runtime operations (store file name)
; r8 - Stores the HQ9+'s counter
; r9 - Unused
; r10 - Unused
; r11 - Unused
; r12 - Unused
; r13 - Unused
; r14 - Unused
; r15 - Unused
; rbp - Unused
; (rsp - Stack pointer, but is it general-purpose?)


SECTION .rodata
	_cant_open_file_error:	db 'Cannot open file. Check if the file ',
				db 'exists and has appropriate ',
				db 'permissions', 0xA
	_cant_open_file_error_len:	equ $-_cant_open_file_error
	_unexpected_fd_error:	db 'File was opened successfully, but ',
				db 'it was given an unexpected ',
				db 'descriptor value. This is an ',
				db 'internal error',0xA
	_unexpected_fd_error_len:	equ $-_unexpected_fd_error


SECTION .text
global _start


process_H:

process_Q:

process_9:

process_plus:


_start:


prepare_source:
	mov rax, 2	; `open` system call
	; Assuming `rdi` contains the file name
	mov rsi, 0	; `O_RDONLY`
	; Don't care what lies in `rdx` because new file will never be
	; created
	syscall

	cmp rax, 0
	jl prepare_source_error_cant_open_file
	cmp rax, 3
	jne prepare_source_error_unexpected_fd
	ret


prepare_source_error_cant_open_file:
	mov rsi, _cant_open_file_error
	mov rdx, _cant_open_file_error_len
	call _print_error

	mov rdi, -1	; Error code -1
	call _exit

prepare_source_error_unexpected_fd:
	mov rsi, _unexpected_fd_error
	mov rdx, _unexpected_fd_error_len
	call _print_error

	mov rdi, -2	; Error code -2
	call _exit


_print_error:
	mov rax, 1	; `write` system call
	mov rdi, 2	; to `stderr`
	; Assuming `rsi` is already set to an error message
	; Assuming `rdx` is already set to the message's length
	syscall
	ret

_exit:
	mov rax, 60	; `exit` system call
	; Assuming `rdi` is already set to an exit code
	syscall
