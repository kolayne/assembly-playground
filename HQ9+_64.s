; This is an HQ9+ interpreter. Read more about the language at wikipedia.
; Usage: <interpreter_executable> <source_file>

; This code uses x86 general-purpose register as follows:
; rax - For system calls and runtime (temporary storage)
; rbx - Stores the HQ9+'s counter
; rcx - Stores the size of the source code
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
	_fstat_failed_error:	db '`fstat` system call failed for '
				db 'unknown reason. This is an '
				db 'internal error', 0xA
	_fstat_failed_error_len:	equ $-_fstat_failed_error


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
	call read_source_code

	; If reached this point, the file has been successfully opened
	; and the file descriptor is `3`

	;

	mov rdi, 0	; Exit code `0`
	jmp _exit


skip_to_next_cmdline_argument:
	; Assuming `rax` is set to the current argument's address
	inc rax
	cmp BYTE [rax], 0
	jnz skip_to_next_cmdline_argument
	inc rax
	ret


read_source_code:
	call _open_file_for_read
	; TODO: probably remove this (currently redundant) logic of
	; checking that fd = 3
	cmp rax, 3
	jne read_source_code_error_unexpected_fd

	; If reached this point, the file is successfully opened and
	; is assigned a file descriptor `3`

	mov rdi, 3
	call _get_file_size

	; TODO: allocate memory for the source code

	; TODO: read the source code

	; TODO: close the file

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


_open_file_for_read:
	mov rax, 2	; `open` system call
	; Assuming `rdi` contains the file name address
	mov rsi, 0	; `O_RDONLY`
	; Don't care what lies in `rdx` because new file will never be
	; created
	syscall

	cmp rax, 0
	jl _open_file_for_read_error_cant_open_file

	ret

_get_file_size:
	; Allocate space on stack for `struct stat` (man 2 stat).
	; Warning: `144` is a value that works on my machine and
	; might differ for other machines (for example, might depend
	; on kernel version)
	sub rsp, 144
	mov rax, 5	; `fstat` system call
	; Assuming `rdi` is set to the file descriptor
	mov rsi, rsp	; where to put the result
	syscall

	cmp rax, 0
	jnz _get_file_size_error_fstat_failed

	; Go to offset `48`, where the file size it located.
	; Warning: `48` is a value that works on my machine and
	; might differ for others! -||-
	add rsp, 48
	; `pop` the file size.
	; Warning: the size takes exactly 8 bytes on my machine,
	; but this might differ for others! -||-
	pop rcx
	; Free the rest of `struct stat`
	; Warning: the structure size on my machine is 48+8+88=144,
	; but this might differ for other machines! -||-
	add rsp, 88

	ret


;; Functions outputting errors


start_error_wrong_arguments_number:
	mov rsi, _wrong_arguments_number_error
	mov rdx, _wrong_arguments_number_error_len
	call _print_error

	mov rdi, -3	; Error code -3
	jmp _exit


_open_file_for_read_error_cant_open_file:
	mov rsi, _cant_open_file_error
	mov rdx, _cant_open_file_error_len
	call _print_error

	mov rdi, -1	; Error code -1
	jmp _exit

read_source_code_error_unexpected_fd:
	mov rsi, _unexpected_fd_error
	mov rdx, _unexpected_fd_error_len
	call _print_error

	mov rdi, -2	; Error code -2
	jmp _exit

_get_file_size_error_fstat_failed:
	mov rsi, _fstat_failed_error
	mov rdx, _fstat_failed_error_len
	call _print_error

	mov rdi, -4	; Error code -4
	jmp _exit
