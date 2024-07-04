global _start

MAX_POLYNOMIAL_LENGTH equ 8
SEGMENT_LENGTH        equ 2
BUFF_SIZE             equ 1024
FILE_DESCRIPTOR_SIZE  equ 4
JUMP_LENGTH           equ 4

SYS_EXIT              equ 60
SYS_OPEN              equ 2
FILE_RDONLY           equ 0
SYS_CLOSE             equ 3
SYS_LSEEK             equ 8
SEEK_CURR             equ 1


section             .bss
buffor:             resw BUFF_SIZE + 8
polynomial:         resw MAX_POLYNOMIAL_LENGTH
polynomial_length:  resw 1
info:               resw JUMP_LENGTH
file_descriptor:    resw FILE_DESCRIPTOR_SIZE
curr_segment_start: resw 8
curr_position:      resw 8

section             .text
_start:
  mov dword [rel file_descriptor], -1
  
  mov rax, [rsp]
  cmp rax, 3
  jne fail

  mov  [rel file_descriptor], rax      ; Store file descriptor
  mov  rdi,                   [rsp+24] ; rdi <- adress of polynomial
  call process_polynomial
  test al,                    al
  jnz  fail

  ; Open file
  mov  rdi,                         [rsp + 16]
  call open
  test eax,                         eax
  js   fail
  mov  dword [rel file_descriptor], eax
  mov  word [rel info],             0

    mov qword [rel curr_segment_start], 0
  mov qword [rel curr_position], 0

  ; Start first segment
  mov  rdi, [rel file_descriptor]
  lea  rsi, [rel info]
  mov  rdx, SEGMENT_LENGTH
  call read

  cmp rax, SEGMENT_LENGTH
  jl  fail

  mov qword [rel curr_segment_start], 0

  ; calculate crc
.calculate_loop:
  mov  rdi, [rel file_descriptor]
  lea  rsi, [rel buffor + MAX_POLYNOMIAL_LENGTH]
  lea  rdx, BUFF_SIZE
  call load_data

  test rax, rax
  js   fail

  mov  r12, rax
  lea  rdi, [rel buffor]
  lea  rsi, [r12 + MAX_POLYNOMIAL_LENGTH]
  call crc

  lea r13,                [rel buffor + MAX_POLYNOMIAL_LENGTH - MAX_POLYNOMIAL_LENGTH]
  add r13,                r12
  mov rdx,                qword [r13]
  mov qword [rel buffor], rdx

  cmp dword [rel file_descriptor], 0
  jge .calculate_loop

  mov qword [rel buffor + MAX_POLYNOMIAL_LENGTH], 0

  lea  rdi, [rel buffor]
  lea  rsi, 16
  call crc

  mov rdx,                qword [rel buffor + MAX_POLYNOMIAL_LENGTH]
  mov qword [rel buffor], rdx

  ; Print results
  movzx rcx, byte [rel polynomial_length]
  xor   edx, edx
  lea   r12, [rel buffor]
  lea   rsp, [rsp + rcx + 1]
  xor   al,  al
  xor   esi, esi
.print_loop:
  mov  dl,              byte [r12]
  shl  byte [r12],      1
  test dl,              dl
  sets dl
  add  dl,              '0'
  mov  byte [rsp +rsi], dl

  inc si
  dec rcx
  jz  .print

  inc al
  cmp al, 8
  jne .bef_loop
  inc r12
  xor al, al
.bef_loop:
  jmp .print_loop

.print:
  movzx rcx,       byte [rel polynomial_length]
  mov   [rsp+rcx], byte `\n`

  lea   rsi, [rsp]
  movzx rdx, byte [rel polynomial_length]
  inc   rdx
  mov   rdi, 1
  mov   rax, 1
  syscall
  
  jmp success


; rdi - adress of polynomial

; al - 0 only when success, -1 otherwise
process_polynomial:
  xor ecx, ecx
  mov rsi, rdi
.convert_loop:
  cmp ecx, 8*MAX_POLYNOMIAL_LENGTH
  ja  .fail
  
  lodsb                       ; Load byte from [rsi] into al and increment rsi
  cmp   al, 0                 ; Check if we've reached the end of the string
  je    .polynomial_processed ; If al == 0, we are done

  shl qword [rel polynomial], 1

  cmp al, '1'
  jne .not_one

  or  qword [rel polynomial], 1
  jmp .before_loop

; report fail on invalid character
.not_one:
  cmp al, '0'
  jne .fail

.before_loop:
  inc rcx
  jmp .convert_loop

.polynomial_processed:
  mov byte [rel polynomial_length], cl
  mov rax,                          8*MAX_POLYNOMIAL_LENGTH
  sub rax,                          rcx
  mov rcx,                          rax
.shift_loop:
  shl  qword [rel polynomial], 1
  loop .shift_loop

  xor eax, eax
  jmp .end

.fail:
  xor al, al
  dec al
.end:
  ret

print_buff:
  push r12
  push r13
  push rcx
  push rax
  push rdx
  push rsi
  lea  rsp, [rsp + 16]

  lea r12, [rel buffor]
  lea r13, [rel buffor + BUFF_SIZE + MAX_POLYNOMIAL_LENGTH -1]
.main_loop:
  mov   rcx, 8
  movzx rdx, byte [r12]
.hexLoop:
  mov  al,             dl
  and  al,             1
  add  al,             '0'
  mov  [rsp+ rcx - 1], al
  shr  rdx,            1
  loop .hexLoop

  mov byte [rsp + 8], ' '
  lea rsi,            [rsp]
  mov rdx,            9
  mov rdi,            1
  mov rax,            1
  syscall

  inc r12
  cmp r12, r13
  jbe .main_loop

  mov [rsp+8], byte `\n`
  lea rsi,     [rsp+8]
  mov rdx,     1
  mov rdi,     1
  mov rax,     1
  syscall

  lea rsp, [rsp - 16]
  pop rsi
  pop rdx
  pop rax
  pop rcx
  pop r13
  pop r12

  ret



; rdi - buffor adress
; rsi - length
crc:
  push r12
  push r13
  push r14
  push r15
  mov  r12, rdi
  mov  r13, rsi
  lea  r15, [r12 + rsi - 8]

.calc_loop:
  cmp r12, r15
  jae .end

  cmp byte [r12], 0
  jnz .calc
  inc r12
  jmp .calc_loop

.calc:
  mov rdx, [rel polynomial]
  xor al,  al
  mov cl,  byte [r12]
  stc
  rcr rdx, 1
  rcr al,  1
.shift_loop:
  test cl, cl
  js   .xor
  shl  cl, 1

  rcr rdx, 1
  rcr al,  1
  jmp .shift_loop
.xor:
  mov rcx, 8
.xor_loop:
  xor  byte [r12+rcx-1],                  dl
  shr  rdx,                               8
  loop .xor_loop
  xor  byte [r12 +MAX_POLYNOMIAL_LENGTH], al
  ;call print_buff
  jmp  .calc_loop

.end:
  pop r15
  pop r14
  pop r13
  pop r12
  ret

; eax - -1 on fail, else file descriptor
open:
  push rbx

  xor  esi, esi
  xor  edx, edx
  mov  eax, SYS_OPEN
  syscall
  test rax, rax
  jns  .success

  xor eax, eax
  dec eax
.success:
  pop rbx
  ret

; rdi - file descriptor
; rsi - adress of buffor
; rdx - bytes count

; rax - bytes read, negative on error
load_data:
  push r12
  push r13
  push r14
  push r15

  mov r12, rdi
  mov r13, rsi
  mov r14, rdx
  mov r15, rdx

.load_loop:
  cmp  word [rel info], 0
  jne  .read
  ; Read jump
  mov  rdi,             r12
  lea  rsi,             [rel info]
  mov  rdx,             JUMP_LENGTH
  call read

  cmp rax, JUMP_LENGTH
  jl  .fail

  mov ecx, dword [rel info]
  ;print_r_hex "Jump to: ", rcx

  ; Jump to next segment
  movsx rsi, dword [rel info]
  mov   rax, SYS_LSEEK
  mov   rdi, r12
  mov   rdx, SEEK_CURR
  syscall

  test rax, rax
  js   .fail

  cmp rax, qword [rel curr_segment_start]
  je  .file_end

  mov qword [rel curr_segment_start], rax
  mov dword [rel info],               0

  ; Read segment's length
  mov  rdi, r12
  lea  rsi, [rel info]
  mov  rdx, SEGMENT_LENGTH
  call read

  cmp rax, SEGMENT_LENGTH
  jl  .fail

.read:
  movzx rdx, word [rel info]
  cmp   rdx, r15
  cmovg rdx, r15
.load:
  mov  rdi, r12
  mov  rsi, r13
  call read

  test rax, rax
  js   .fail

  sub r15,             rax
  sub word [rel info], ax
  mov r11,             rax

  add r13, r11

  cmp r15, 0
  jne .load_loop

jmp .all_read

.file_end:
  call close

.all_read:
  mov rax, r14
  sub rax, r15
  jmp .end

.fail:
  xor eax, eax
  dec rax

.end:
  pop r15
  pop r14
  pop r13
  pop r12
  ret

; Reads data from file
; rdi - file descriptor
; rsi - adress of buffor
; rdx - bytes count

; rax - bytes read, negative only on error
read:
  push r12
  push r13
  mov  r12, rdx
  mov  r13, rdx
.loop:
  mov rdi, rdi
  mov rdx, r12
  xor eax, eax
  syscall

  cmp rax, 0
  js  .fail
  je  .end

  add qword [rel curr_position], rax
  sub r12,                       rax
  jnz .loop

  cmp r12, 0
  jne .fail
  mov rax, r13
  jmp .end

.after:
  mov rax, r13
  sub r13, r12
  jmp .end

.fail:
  xor eax, eax
  dec rax

.end:
  pop r13
  pop r12
  ret

close:
  push rbx
  cmp  dword [rel file_descriptor], 0
  jl   .end
  
  mov rdi, rbx
  mov rax, SYS_CLOSE
  syscall

  mov dword [rel file_descriptor], -1

.end:
  pop rbx
  ret

success:
  xor edi, edi
  jmp end

fail:
  xor edi, edi
  inc edi
  jmp end

end:
  push rbx

  mov  rbx, rdi
  call close
  mov  rdi, rbx
  
  pop rbx
  
  mov rax, SYS_EXIT
  syscall