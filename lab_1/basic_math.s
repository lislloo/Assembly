
DEFAULT REL

global _start
; Data
section .data
	
a dw 2
b dw 45
c dd 9
d dd 9
e dd 1
result dq 0
section .text

_start:

;   (A * C) / B
	movsx rax, word [a] 
	movsxd rcx, dword [c] 
	imul rax, rcx
	jo overflow

	movsx rcx, word [b]
	test rcx, rcx
	jz div_zero

	cqo
	idiv rcx
	mov r8, rax

; (D * B) / E
	movsxd rax, dword [d]
	movsx rbx, word [b]
	imul rbx
	jo overflow

	movsxd rcx, dword [e]
	test rcx, rcx
	jz div_zero

	cqo
	idiv rcx
	mov r9, rax


; (C * C [c^2]) / (A * D)
	movsxd rax, dword [c];
	imul rax, rax
	jo overflow
	mov r10, rax

	movsx rax, word [a];
	movsxd rcx, [d];
	imul ecx
	jo overflow

	
	test rax, rax
	jz div_zero

	;
	mov rcx, rax ; знаменатель
	mov rax, r10 ; числитель
	;
	cqo
	idiv rcx
	mov r11, rax

; summ
	mov rax, r8
	add rax, r9
	jo overflow

	sub rax, r11
	jo overflow

	mov r15, rax
	mov [result], r15
	;good
	mov rax, 60
	mov rdi, 0
	syscall
	
overflow:
	mov rax, 60
	mov rdi, 2
	syscall

div_zero:
	mov rax, 60
	mov rdi, 1
	syscall
