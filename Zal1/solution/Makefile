CC = gcc
CFLAGS = -Wall -Wextra -Wno-implicit-fallthrough -std=gnu17 -fPIC -O2

.PHONY: all clean

list.o: list.c list.h nand.h
connection.o: connection.c connection.h nand.h
nand.o: nand.c nand.h socket.h connection.h list.h
socket.o: socket.c socket.h nand.h connection.h
memory_tests.o: memory_tests.h memory_tests.c
nand_example.o: nand_example.c nand.h memory_tests.h

nand_example: nand_example.o libnand.so
	$(CC) $(CFLAGS) -o $@ $< -L. -lnand

libnand.so: nand.o list.o connection.o socket.o memory_tests.o
	$(CC) -shared -Wl,--wrap=malloc -Wl,--wrap=calloc -Wl,--wrap=realloc -Wl,--wrap=reallocarray -Wl,--wrap=free -Wl,--wrap=strdup -Wl,--wrap=strndup -o $@ $^

clean:
	rm -rf nand_example *.so *.o