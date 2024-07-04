%ifndef MACRO_PRINT_R_HEX_ASM
%define MACRO_PRINT_R_HEX_ASM

%macro print_r_hex 2
  jmp %%begin
%%descr: db  %1
%%leng:  equ $ - %%descr
%%begin:
  push %2              ; Wartość do wypisania będzie na stosie. To działa również dla %2 = rsp.
  lea  rsp, [rsp - 16] ; Zrób miejsce na stosie na bufor. Nie modyfikuj znaczników.
  pushf
  push rax
  push rcx
  push rdx
  push rsi
  push rdi
  push r11

  lea rsi, [rel %%descr]
  mov rdx, %%leng
  mov rdi, 1
  mov rax, 1
  syscall

  mov rdx, [rsp+72]
  mov rcx, 16
  mov rdx, [rsp + 72]
%%hexLoop:
  mov al, dl
  and al, 0xF
  cmp al, 9
  jg  %%letter
  add al, '0'
  jmp %%hexLoop_end
%%letter:
  add al, 'A'
  sub al, 10
%%hexLoop_end:
  mov  [rsp+rcx+56-1], al
  shr  rdx,            4
  loop %%hexLoop

  mov [rsp+72], byte `\n`
  lea rsi,      [rsp+56]
  mov rdx,      17
  mov rdi,      1
  mov rax,      1
  syscall

  pop r11
  pop rdi
  pop rsi
  pop rdx
  pop rcx
  pop rax
  popf
  lea rsp, [rsp + 24]
%endmacro

%endif