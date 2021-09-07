; This is an HQ9+ interpreter. Read more about the language at wikipedia.
; Usage: <interpreter_executable> <source_file>

; This code uses x86 general-purpose register as follows:
; rax - For system calls and runtime (temporary storage)
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
	; Note: the "constants" defined in rodata have a preceeding
	; underscroe if they're "internal", not related to HQ9+ iteslf,
	; and don't have it if their values have something to do with
	; the language-produced results

	_wrong_arguments_number_error:	db 'There must be exactly one '
					db 'command-line argument (path '
					db 'to file) given to the ',
					db 'interpreter', 0xA
	_wrong_arguments_number_error_len: \
		equ $-_wrong_arguments_number_error
	_cant_open_file_error:	db 'Cannot open file. Check if the file ',
				db 'exists and has appropriate ',
				db 'permissions', 0xA
	_cant_open_file_error_len:	equ $-_cant_open_file_error
	_unexpected_fd_error:	db 'File was opened successfully, but ',
				db 'it was given an unexpected ',
				db 'descriptor value. This is an ',
				db 'internal error', 0xA
	_unexpected_fd_error_len:	equ $-_unexpected_fd_error


SECTION .text
global _start


;; Language interpretation functions


process_H:

process_Q:

process_9:

process_plus:


;; Internal interpreter functions


_start:
	pop rax	; Number of cmd-line arguments
	cmp rax, 2
	jl start_error_wrong_arguments_number

	pop rax	; cmd-line arguments' storage address
	call skip_to_next_cmdline_argument

	mov rdi, rax
	call prepare_source

	; If reached this point, the file has been successfully opened
	; and the file descriptor is `3`

	; TODO: do logic here

	mov rdi, 0	; Exit code `0`
	jmp _exit


skip_to_next_cmdline_argument:
	; Assuming `rax` is set to the current argument's address
	inc rax
	cmp BYTE [rax], 0
	jnz skip_to_next_cmdline_argument
	inc rax
	ret


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


;; Helper functions


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


;; Functions outputting errors


start_error_wrong_arguments_number:
	mov rsi, _wrong_arguments_number_error
	mov rdx, _wrong_arguments_number_error_len
	call _print_error

	mov rdi, -3	; Error code -3
	jmp _exit


prepare_source_error_cant_open_file:
	mov rsi, _cant_open_file_error
	mov rdx, _cant_open_file_error_len
	call _print_error

	mov rdi, -1	; Error code -1
	jmp _exit

prepare_source_error_unexpected_fd:
	mov rsi, _unexpected_fd_error
	mov rdx, _unexpected_fd_error_len
	call _print_error

	mov rdi, -2	; Error code -2
	jmp _exit
