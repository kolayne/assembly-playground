SECTION .text
	global _start

input_one_byte_integer:
	sub esp, 1	; Allocate one byte on stack

	mov eax, 3	; Read system call
	xor ebx, ebx	; From stdin
	mov ecx, esp	; Read to stack
	mov edx, 1	; Read only one byte
	int 0x80	; Invoke call!

	mov al, [esp]	; Should work... Copy the read integer to the AL register
	sub al, 48	; Substract ord('0')
	mov al, al	; (pointless) Explicitly set the result as the function's return value
	
	add esp, 1	; Free the byte on stack
	ret		; The function's finished

_start:
	call input_one_byte_integer	; Input an integer

	movsx ebx, al	; Use the read integer as the exit code
	mov eax, 1	; Exit
	int 0x80	; Invoke call!
