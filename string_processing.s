; maybe it should delete
bits 64

;reverse symbols in words
section .data
	size  equ 1024
	msg1:
		db "Enter in_string: "
	msg1len equ $-msg1
	; errors
	err_msg db "Error", 10
	err_len equ $-err_msg
msg2:
	db "Result: "

section .bss
	in_str resb size
	newin_str resb size
	out_fd resq 1
section .text
global _start
_start:
	;taking name of output file
	pop rax
	cmp rax, 2
	jne error_exit
	pop rax
	pop rdi ; name of output file
	mov rax, 2 ;sys_open
	mov rsi, 577 ; O_WRONLY + O_CREAT + O_TRUNC
	mov rdx, 0644o ; rights
	syscall
	test rax, rax ; check good open
	js error_exit
	mov [out_fd], rax  ; saving descriptor
	;print first message
	mov eax, 1
	mov edi, 1
	mov rsi, msg1
	mov edx, msg1len
	syscall

read_loop:
	xor rax, rax
	xor rdi, rdi
	mov rsi, in_str
	mov rdx, size
	syscall

	test rax, rax
	jz good ; if 0 byte
	js error_exit ; if error

	mov rsi, in_str
	mov rdi, newin_str
	xor ecx, ecx

	mov r10, rax ; all bytes
	xor r11, r11 ; 0

parsing_word:    ; parsing
	mov al, [rsi]
	inc rsi
	inc r11 ;
	cmp al, 10 ; checks \n
	je check_word
	cmp al, ' ' ; checks space
	je check_word
	cmp al, 9 ; checks tab
	je check_word
	inc ecx ;
	cmp r11, r10
	je check_word

	jmp parsing_word
check_word:
	jecxz check_end
	cmp rdi, newin_str ; if this first word?
	je prepare_reverse
	mov byte[rdi], ' '
	inc rdi
prepare_reverse:
	mov rdx, rsi
	dec rdx
reverse_loop:
	dec rdx
	mov bl, [rdx]
	mov [rdi], bl
	inc rdi
	loop reverse_loop
check_end:

	cmp r11, r10
	jl parsing_word

	mov byte[rdi], 10 ; add \n
	inc rdi

	mov rdx, rdi ;end address
	sub rdx, newin_str  ; length
	;
	mov rax, 1	;sys_write
	mov rdi, [out_fd]
	mov rsi, newin_str
	syscall
	jmp read_loop ;new str
	
good:
	mov rax, 3	; sys_close
    	mov rdi, [out_fd]
    	syscall
    	xor rdi, rdi   ;0
    	jmp exit
error_exit:
	mov rax, 1
    mov rdi, 2          ; stderr
    mov rsi, err_msg
    mov rdx, err_len
    syscall
exit:
	mov eax, 60
	syscall

