.PHONY: all clean

all: crc

crc.o: crc.asm
	nasm -g -f elf64 -w+all -w+error -o crc.o crc.asm

crc: crc.o macro_print_r_hex.o macro_print_r_bin.o
	ld --fatal-warnings -o crc crc.o macro_print_r_hex.o macro_print_r_bin.o

macro_print_r_hex.o: macro_print_r_hex.asm
	nasm -g -f elf64 -w+all -w+error -o macro_print_r_hex.o macro_print_r_hex.asm

macro_print_r_bin.o: macro_print_r_bin.asm
	nasm -g -f elf64 -w+all -w+error -o macro_print_r_bin.o macro_print_r_bin.asm

clean:
	rm -rf crc crc2 *.o