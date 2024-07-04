.PHONY: all clean

all: mdiv_asm

mdiv.o: mdiv.asm
	nasm -g -f elf64 -w+all -w+error -o mdiv.o mdiv.asm

mediator.o: mediator.c
	gcc -c -std=c17 -O2 -o $@ $<

mdiv_asm: mdiv.o mediator.o
	gcc -z noexecstack -o $@ $^

clean:
	rm -rf mdiv_asm *.o
