global _start

%define SQUARE 1 ; 1-КВАДРАТНАЯ  0-ПРЯМОУГОЛЬНАЯ

;

section .data
matrix:
    db 3    ; rows r9
%if SQUARE == 0
    db 4    ; columns r10
%endif

matrix_data:
    align 1;
    ;db 5, 2, -3, 7
    ;db -1, 4, 8, 0
    ;db 6, -2, 9, 1

    db 5, -3, 7
    db -1, 8, 0
    db 6, 9, 1

section .bss
    col_ptrs resq 255 ; массив указателей
    buffer   resb 65025 ; буфер

section .text

_start:
    movzx r9, byte [matrix]      ; r9 = rows
%if SQUARE
    mov r10, r9
%else
    movzx r10, byte [matrix + 1] ; r10 = columns
%endif
    lea rsi, [matrix_data]        ; rsi - адрес первого элемента
    lea rdi, [col_ptrs]		; rdi - начало массива указателей
    xor rcx, rcx 		; rcx - счетчик столбцов(=0)

init_ptrs_loop:
    cmp rcx, r10            ;проходимся по всем столбцам
    je sorting_stage
    mov [rdi + rcx*8], rsi       ; адрес начала каждого столбца в col_ptrs
    inc rsi                      ; gереходим к следующему столбцу
    inc rcx
    jmp init_ptrs_loop

; сортировка
sorting_stage:   ; построение кучи
    mov rbx, r10
    shr rbx, 1
    dec rbx             ; rbx = (r10 / 2) - 1

build_heap_loop:        ;получаем пирамиду
    cmp rbx, 0
    jl start_extraction
    mov rdi, rbx        ; индекс корня
    mov rdx, r10        ; размер кучи
    call heapify	; просеиваем
    dec rbx
    jmp build_heap_loop

start_extraction:
    mov rbx, r10
    dec rbx             ; rbx = индекс последнего элемента

sort_loop:
    cmp rbx, 0
    jle copy_to_buffer
    mov rax, [col_ptrs]   ; rax = начальный элемент в col_ptrs
    mov r8,  [col_ptrs + rbx * 8] ; r8 = последний элемент в col_ptrs
    ; меняем их местами (heap_sort)
    mov [col_ptrs], r8
    mov [col_ptrs + rbx * 8], rax
    ;
    mov rdi, 0          ; просеиваем новый корень
    mov rdx, rbx
    call heapify
    dec rbx
    jmp sort_loop

; в буфер и обратно
copy_to_buffer:
    xor r12, r12        ; r12 = текущая строка
    lea rdi, [buffer]   ; rdi = адрес буфера

row_loop:
    ;cmp r12b, [matrix]
    cmp r12, r9
    je apply_buffer
    xor r13, r13        ; r13 = текущий столбец

col_copy_loop:
    cmp r13, r10
    je next_row
    mov rsi, [col_ptrs + r13 * 8]	; rsi = адрес самого верхнего элемента
    mov rax, r10			
    mul r12				; смещение вниз
    mov al, [rsi + rax]
    mov [rdi], al
    inc rdi
    inc r13
    jmp col_copy_loop

next_row:
    inc r12
    jmp row_loop
;
apply_buffer:
    movzx rax, byte [matrix]
    mov rbx, r10
    mul rbx
    mov rcx, rax        ; cколько байт копировать
    lea rsi, [buffer]
    lea rdi, [matrix_data]
    rep movsb		; копирование из rsi в rdi rcx раз

exit:
    mov rax, 60
    xor rdi, rdi
    syscall


heapify:
    push rbx
    push r12
    push r13

    mov r12, rdi        ; r12 = i
    mov r13, rdi        ; r13 = largest

    ; левый ребенок
    lea rbx, [r12 * 2 + 1]
    cmp rbx, rdx        ; rdx = размер кучи
    jge .check_right

    lea rdi, [col_ptrs + rbx * 8]	; rdi = фдрес левого ребенка
    lea rsi, [col_ptrs + r13 * 8]	; rsi = адрес юольшего элемента
    call compare_columns
    %ifdef REVERSE
	jg .not_larger_left
    %else
    	jl .not_larger_left
    %endif
    mov r13, rbx

.not_larger_left:
.check_right:
    lea rbx, [r12 * 2 + 2]
    cmp rbx, rdx
    jge .check_done

    lea rdi, [col_ptrs + rbx * 8]	; rdi = адреc правого ребенка
    lea rsi, [col_ptrs + r13 * 8]	; rsi = адрес большего элемента
    call compare_columns
    %ifdef REVERSE
	jg .check_done
    %else
    	jl .check_done
    %endif
    mov r13, rbx

.check_done:
    cmp r13, r12
    je .h_exit

    ; обмен указателей в col_ptrs
    mov rax, [col_ptrs + r12 * 8]
    mov r8,  [col_ptrs + r13 * 8]
    mov [col_ptrs + r12 * 8], r8
    mov [col_ptrs + r13 * 8], rax

    mov rdi, r13
    call heapify

.h_exit:
    pop r13
    pop r12
    pop rbx
    ret
; сравнение столбцов
compare_columns:
    push rdi
    push rsi
    push rdx
    push r11

    mov rdi, [rdi]      ; достаем адрес столбца из указателя
    call get_min_col
    mov r11b, al

    mov rdi, [rsi]      ; адрес второго столбца
    call get_min_col    ; минимум второго в al

    cmp r11b, al

    pop r11
    pop rdx
    pop rsi
    pop rdi
    ret

; поиск минимума
get_min_col:
    push rcx
    push rsi
    push rbx

    movzx rcx, byte [matrix]    ; количество строк
    mov rsi, rdi		; адрес начала столбца
    mov al, [rsi]		; первый элемент(как минимум)
    mov rbx, r10

.min_loop:
    mov dl, [rsi]
    cmp dl, al
    jge .not_smaller
    mov al, dl
.not_smaller:
    add rsi, rbx
    loop .min_loop

    pop rbx
    pop rsi
    pop rcx
    ret
