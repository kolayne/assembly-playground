SECTION .rodata
	msg:		db 'Hello world!',0xA
	msg_len:	equ $-msg

SECTION .text
	global _start

_start:
	mov eax, 4
	mov ebx, 2	; Print to stderr just for a change
	mov ecx, msg
	mov edx, msg_len
	int 0x80

	mov eax, 1
	xor ebx, ebx
	int 0x80
