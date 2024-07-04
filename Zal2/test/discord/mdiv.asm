global  mdiv

; On input:
; rdi - adress of array
; rsi - n - number of segments
; rdx - divider

; r8 - divider
; r9b - if divident was negative (1 if so, 0 else)
; r10b - lsb: 1 if divider was negative, else 0 ; msb: 1 on second negation, 0 else
; r11 - adress of most significant byte of divident

section .text
mdiv:
  mov r8,  rdx              ; divider will be stored in r8
  lea r11, [rdi + 8*rsi -1]

; negate divider if negative
  test r8, r8            ; check if divider is negative
  sets r10b              ; r10b is 1 if true, else 0
  jns  .prepare_divident ; if divider positive, do not negate
  neg  r8

.prepare_divident:
  cmp  byte [r11], 0 ; if divident is negative
  sets r9b           ; r9b is 1 if divident negative, else 0
  jns  .divide       ; if positive, skip negation

; negate divident
.negate:
  xor edx, edx ; index of current segment
  mov rcx, rsi ; rcx - loop iterator
  stc          ; set carry as we need to add 1
.negate_loop:
  not  qword [rdi + 8*rdx]
  adc  qword [rdi + 8*rdx], 0
  inc  rdx
  loop .negate_loop

; if it is the second negation, jump to appropriate moment (if it is, msb in r10b is 1)
  test r10b, r10b
  js   .negate_mod

.divide:
  xor edx, edx ; edx <- 0
  mov rcx, rsi ; rcx - loop iterator
.div_loop:
  mov  rax,               [rdi + 8*rcx - 8] ; move segment for division rax (rcx-1 segment)
  div  r8
  mov  [rdi + 8*rcx - 8], rax               ; move results back
  loop .div_loop

; process data after division
.aftDiv:  
  mov rax,  rdx ; rax <- mod of whole division
  xor r10b, r9b ; check if results should be negated
  jz  .ovf      ; if not, skip negation
  not r10b      ; set flag that it is second negation
  jmp .negate   ; negate
  
; check for overflow
.ovf:
  cmp byte [r11], 0 ; results were not negated, check the MSB
  jnl .negate_mod   ; if not, prepare modulo
  div cl            ; overflow, report (cl is zero from division loop)

; negate modulo
.negate_mod:
  test r9b, r9b ; check if modulo should be negated
  jz   .end     ; if not, skip
  neg  rax

.end:
  ret 
