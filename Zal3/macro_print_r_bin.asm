%ifndef MACRO_PRINT_R_BIN_ASM
%define MACRO_PRINT_R_BIN_ASM

%macro print_r_bin 2
  jmp %%begin
%%descr: db  %1
%%leng:  equ $ - %%descr
%%begin:
  push %2              ; Wartość do wypisania będzie na stosie. To działa również dla %2 = rsp.
  lea  rsp, [rsp - 64] ; Zrób miejsce na stosie na bufor. Nie modyfikuj znaczników.
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

  mov rcx, 64
  mov rdx, [rsp + 7*8 + 64]
%%hexLoop:
  mov  al,             dl
  and  al,             1
  add  al,             '0'
  mov  [rsp+rcx+56-1], al
  shr  rdx,            1
  loop %%hexLoop

  mov [rsp+56 + 64], byte `\n`
  lea rsi,           [rsp+56]
  mov rdx,           64+1
  mov rdi,           1
  mov rax,           1
  syscall

  pop r11
  pop rdi
  pop rsi
  pop rdx
  pop rcx
  pop rax
  popf
  lea rsp, [rsp + 64 - 8]
%endmacro

%endif