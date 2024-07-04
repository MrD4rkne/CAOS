#!/bin/bash


if ! test -f crc.asm; then
    echo "Compilation error: file crc.asm not found."
    exit 1
fi

echo "Compiling crc.asm last modified $(stat -c %y gen.py)."

if ! nasm -f elf64 -w+all -w+error -o crc.o crc.asm; then
    echo Compilation failed!
    exit 1
fi

if ! ld --fatal-warnings -o crc crc.o; then
    echo Linking failed!
    exit 1
fi

echo Compilation sucess!


