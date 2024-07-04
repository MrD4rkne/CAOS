global _start

POL_LENGTH           equ 8
SEGMENT_LENGTH       equ 2
; BUFF_SIZE is based on several benchmarks,
; making it bigger does not change
; the performence of program by much
BUFF_SIZE            equ 65535
FILE_DESCRIPTOR_SIZE equ 4
JUMP_LENGTH          equ 4
FILE_NOT_OPENED      equ -1

SYS_EXIT             equ 60
SYS_OPEN             equ 2
SYS_CLOSE            equ 3
SYS_LSEEK            equ 8
SEEK_CURR            equ 1


section             .bss
buffor:             resb BUFF_SIZE + 8        ; + 8 to have space for results
polynomial:         resb POL_LENGTH
polynomial_length:  resb 1
info:               resb JUMP_LENGTH
file_descriptor:    resb FILE_DESCRIPTOR_SIZE
curr_segment_start: resb 8
crctab:             resb 256 * 8

section             .text

; convert polynomial from [rsp + 24] to [polynomial]
%macro process_polynomial 0
  xor edx, edx        ; rdx <- register with one 1 starting from MSb
  mov rsi, [rsp + 24] ; rsi <- adress of polynomial
  xor ecx, ecx        ; rcx - polynomial
  xor r8b, r8b        ; r8b - polynomial's length counter

  stc ; seed MSb in rdx
.convert_loop:
  rcr rdx, 1
  
  lodsb                       ; Load byte from [rsi] into al and increment rsi
  cmp   al, 0                 ; Check if we've reached the end of the string
  je    .polynomial_processed ; If al == 0, we are done

  test rdx, rdx ; Check if polynomial is not too long
  jz   .fail

  cmp al, '1'  ; if 1, set bit
  jne .not_one ; otherwise, check if valid char

  or  rcx, rdx
  jmp .before_loop

; report fail on invalid character (not '1' and not '0')
.not_one:
  cmp al, '0'
  jne .fail   ; jump on invalid char

.before_loop:
  inc r8b
  jmp .convert_loop

.polynomial_processed:
  test r8b, r8b
  jz   .fail
  
  mov byte [rel polynomial_length], r8b ; save polynomial's length
  mov qword [rel polynomial],       rcx ; save polynomial

%endmacro

; generate crc look-up table with [polynomial]
; based on i, i \in {0, 1, ... ,255} we calculate
; what the next 8 bytes should be xored with
; this way we avoid aligning polynomial
; with the most significant non-zero bit in data
%macro crc_init 0
  lea r8,  [rel crctab] ; r8 <- adress of crc table
  mov ecx, 1            ; cl - iterator i
.init_loop:
  mov dil, cl ; dil <- i

  ; rdx <- 8 MSb of polynomial
  mov rdx, [rel polynomial]
  shr rdx, 56

  ; rsi <- 56 LSb of polynomial
  mov rsi, [rel polynomial]
  shl rsi, 8

  mov r11, 7   ; r11 - counter i
  xor eax, eax ; rax - results

.xor_loop:
  ; move polynomial to the right between two registers
  rcr dl,  1
  rcr rsi, 1

  bt  di,  r11w ; test i-bit
  jnc .no_xor
  ; if it is set to 1, xor
  xor dil, dl
  xor rax, rsi
.no_xor:
  dec r11b
  jns .xor_loop

  bswap rax
  mov   qword [r8 + 8 * rcx], rax
  inc   cl
  jnz   .init_loop
  
%endmacro


; load BUFF_SIZE of data from file [file_descriptor]
; to buffor+8
; rax - bytes read, negative on error
%macro load_data 0
  lea r13, [rel buffor + 8] ; r13 <- buffor + 8
  mov r15, BUFF_SIZE        ; r15 - how many bytes can fit in buffor

.load_loop:
  ; If there are unreaded bytes in current segment
  cmp word [rel info], 0
  jne .read

  ; If not, read jump
  lea  rsi, [rel info]
  mov  rdx, JUMP_LENGTH
  call read
  ; Check for failure
  cmp  rax, JUMP_LENGTH
  jl   .fail

  ; Jump to next segment
  movsx rsi, dword [rel info]
  mov   rax, SYS_LSEEK
  mov   rdi, [rel file_descriptor]
  mov   rdx, SEEK_CURR
  syscall
  ; Check for failure
  test  rax, rax
  js    .fail

  ; If jumped to the same position as current segment starts, EOF
  cmp rax, qword [rel curr_segment_start]
  je  .all_read

  ; If not, set new segment's start offset
  mov qword [rel curr_segment_start], rax

  ; Read segment's length
  lea  rsi, [rel info]
  mov  rdx, SEGMENT_LENGTH
  call read

  cmp rax, SEGMENT_LENGTH
  jl  .fail

.read:
  ; Get min (spaceInBuffor, availableBytesInSegment)
  movzx rdx, word [rel info]
  cmp   rdx, r15
  cmovg rdx, r15
  mov   rbx, rdx
.load:
  ; Read bytes into buffor
  mov  rsi, r13
  call read

  ; Check for failure
  test rax, rax
  cmp  rax, rbx
  jl   .fail

  sub r15,             rax ; update how much space in buffor left
  sub word [rel info], ax  ; update how many bytes in segment left

  add r13, rax ; shift buffor's pointer

  cmp r15, 0     ; If buffor has space, try read more
  jne .load_loop

.all_read:
  ; Finished reading, calculate how many bytes read
  mov rax, BUFF_SIZE
  sub rax, r15       ; rax <- BUFF_SIZE - space left

%endmacro



_start:
  mov dword [rel file_descriptor], FILE_NOT_OPENED

  ; Check arguments count
  mov rax, [rsp]
  cmp rax, 3
  jne .fail

  process_polynomial

  ; Open file
  mov rdi, [rsp + 16] ; rdi <- adress of file's path
  xor esi, esi        ; rsi <- 0
  xor edx, edx        ; rdx <- 0
  mov eax, SYS_OPEN
  syscall

  test eax, eax
  js   .fail

  ; Prepare for calculation
  mov dword [rel file_descriptor],    eax ; save file descriptor
  mov qword [rel curr_segment_start], 0
  
  crc_init ; init look-up table

  ; Read info about first segment
  lea  rsi, [rel info]
  mov  rdx, SEGMENT_LENGTH
  call read
  cmp  rax, SEGMENT_LENGTH
  jl   .fail

  ; Calculate crc
.calculate_loop:
  ; Load data into buffor (but skip 8 first bytes of buffor)
  load_data

  test rax, rax
  js   .fail

  ; Check if buffor was loaded fully
  cmp  rax, BUFF_SIZE
  setb r14b           ; If not: r14b <- 1

  mov r12, rax ; r12 <- number of bytes read

  ; Calculate crc on buffor
  ; 8 first bytes in buffor are from previous crc call (or 0),
  ; last 8 bytes will be only xored, but not determine polynomial
  lea  rdi, [rel buffor]
  lea  rsi, [r12]        ; buffor's length
  call crc

  ; Copy remaining bytes to the beginning of the buffor
  lea r13,                [rel buffor]
  mov rdx,                qword [r13  + r12]
  mov qword [rel buffor], rdx

  ; If file is still open, repeat
  test r14b, r14b
  jz   .calculate_loop

  ; Calculate remainder
  mov qword [rel buffor + POL_LENGTH], 0 ; reset result

  lea  rdi, [rel buffor]
  lea  rsi, 8
  call crc

  ; Now remainder is at buffor + POL_LENGTH, because
  ; first 8 bytes were data, other 8 bytes were equal to 0,
  ; so after crc these 0-equal bytes are remainder

  ; Print results
  lea   rax, [rel buffor + POL_LENGTH]    ; rax <- adress of remainder
  mov   rax, qword [rax]                  ; rax <- remainder
  bswap rax                               ; printing will be simpler
  xor   rdi, rdi                          ; rdi <- counter of printed bits
  movzx rcx, byte [rel polynomial_length] ; rcx <- polynomial's length
  lea   r13, [rcx + 1]                    ; r13 <- number of bytes to print
  lea   r12, [rel buffor]
.to_text_loop:
  ; Determine if '1' or '0' now
  test rax,              rax
  sets dl                    ; dl = 1 <=> MSb of rax is 1
  add  dl,               '0'
  mov  byte [r12 + rdi], dl

  shl  rax, 1
  inc  rdi
  loop .to_text_loop

  mov [r12+rdi], byte `\n`

  ; Call print
.print_loop:
  mov rdx, r13
  lea rsi, [r12]
  mov rdi, 1
  mov rax, 1
  syscall

  test rax, rax
  js   .fail

  add r12, rax    ; shift by written bytes
  sub r13, rax    ; substract written bytes
  jnz .print_loop ; jump if all was written

  ; Success
  xor edi, edi
  jmp .end

.fail:
  xor edi, edi
  inc edi

; Clean-up before exiting
.end:
  mov rbx, rdi

  ; Try close file if opened
  cmp dword [rel file_descriptor], FILE_NOT_OPENED
  je  .exit
  
  ; Close file
  mov edi, [rel file_descriptor]
  mov rax, SYS_CLOSE
  syscall

  ; Set file closed (or atleast tried)
  mov dword [rel file_descriptor], FILE_NOT_OPENED

  ; Check for error
  test rax, rax
  js   .fail

.exit:
  ; Exit
  mov rdi, rbx
  mov rax, SYS_EXIT
  syscall

; calculate crc for bytes bytes in buffor
; rdi - buffor adress
; rsi - length
crc:
  lea r9,  [rel crctab] ; r9 <- adress of look-up table
  lea rcx, [rsi]        ; rcx <- number of bytes to process
  mov rsi, rdi          ; rsi <- adress of buffor

.calculate_loop:
  dec rcx
  js  .end

  lodsb                           ; al <- next byte in buffor, increment rdi
  and   rax, 0xFF                 ; make sure rax \in {0, 1, 255}
  mov   rax, qword [r9 + 8 * rax] ; rax <- polynomial from look-up table

  xor qword [rsi], rax ; xor next 8 bytes of buffor with polynomial
  jmp .calculate_loop

.end:
  ret

; Reads data from file
; rsi - adress of buffor
; rdx - bytes count
; Returns:
; rax - bytes read, negative only on error
read:
  push r12
  push r13
  push r14
  
  mov r12, rdx                   ; r12 - how many bytes to read
  mov r13, rdx                   ; r13 - ho wmany bytes were ordered
  mov rdi, [rel file_descriptor]
.read_loop:
  ; Read from file
  mov rdx, r12
  xor eax, eax
  syscall

  cmp rax, 0
  jl  .fail     ; on failure
  je  .file_end ; on file end

  sub r12, rax   ; update how many bytes to read
  jnz .read_loop

.file_end:
  ; Calculate how many bytes were actually read
  sub r13, r12
  mov rax, r13
  jmp .end

.fail:
  xor eax, eax
  dec rax

.end:
  pop r14
  pop r13
  pop r12
  ret
