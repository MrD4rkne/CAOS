global  mdiv

; MSF - most significant fragment
; LSB - less significant bit

section .text
; rdi - address of array
; rsi - n, n>0
; rdx - divider
mdiv:
  cmp rdx, 0
  je  overflow
.set_flags:

; set flags in r9
  mov r8,                  rdx           ; r8 <- divider
  lea rcx,                 [rsi - 1]     ; rcx <- n-1
  mov r9,                  [rdi + 8*rcx] ; r9 <- MSF
  xor r9,                  rdx
  rcl r9,                  2             ; <- on LSB 1 if signs of divident and divider differ, else 0
  and r9,                  1
  cmp qword [rdi + 8*rcx], 0             ; check if divident is negative
  jnl .negateDivident
  or  r9,                  2             ; divident negative, set 2nd LSB 1

; negate divident if neccessary
.negateDivident:
  mov  rdx, 2
  and  rdx, r9        ; check 2nd LSB
  jz   .negateDivider ; if divident positive, do not negate
  call negate         ; negate divident

; negate divider if neccessary
.negateDivider:
  cmp r8, 0   ; check if divider is negative
  jge .divide ; if not, skip negation
  not r8      ; negate
  add r8, 1

.divide:
  lea rcx,           [rsi-1]       ; rcx <- n-1
  mov rax,           [rdi + 8*rcx] ; rax <- most significant segment
  xor edx,           edx           ; reset rdx
  div r8                           ; rax/r8 (rdx is 0)
  mov [rdi + 8*rcx], rax           ; put result of division instead of MSF
  cmp rcx,           0
  je  .aftlp                       ; skip further division if n-1==0
  dec rcx                          ; rcx <- n-2; rcx:=i
.divlp:
  mov rax,           [rdi + 8*rcx] ; rax <- x[i]
  div r8                           ; rdx:rax / r8 (in rdx is mod of previous division)
  mov [rdi + 8*rcx], rax           ; put result of division instead of x[i]
  dec rcx                          ; i--
  jns .divlp                       ; loop when i>=0

; prepare result
.aftlp:
  mov  rax, rdx        ; rax <- mod from last division)
  mov  r8,  r9         ; r8 <- 1 if result should be negated, 0 else
  and  r8,  1          ; check if result should be negated
  jz   .check_overflow ; if not, skip
  call negate

  jmp .negateMod

; if number should be positive, check for overflow
.check_overflow:
  lea rcx, [rsi-1]
  mov rdx, [rdi + 8*rcx]
  rcl rdx, 2
  and rdx, 1
  jnz overflow
  
; negate mod if neccessary
.negateMod:
  and r9,  2 ; check if mod should be negated
  jz  .end   ; if not, skip negation
  not rax
  add rax, 1
  
.end:
  ret

negate:
  mov rdx, 0
  mov rcx, rsi

; not all segments
.negate_loop:
  not  qword [rdi + 8*rdx]
  inc  rdx
  loop .negate_loop
  
; add one
  mov rdx, 0
.add_loop:
  cmp rdx,                 rsi
  je  .negate_ret
  add qword [rdi + 8*rdx], 1
  inc rdx
  jc  .add_loop                ; repeat for next segment if carry

.negate_ret:
  ret

overflow:
  mov r8, 0
  div r8
  ret