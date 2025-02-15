#!/bin/bash

VG_FLAGS="-s --error-exitcode=123 --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all --track-origins=yes"

vg=0

while getopts 'vn:' OPTION; do

    case "$OPTION" in
        v)
            vg=1
            ;;
        ?)
            echo "Script usage: [-v]"
            exit 1
            ;;
    esac
done

if ! make libnand.so; then
    echo -e "\e[31mCompilation of libnand.so failed! Aborting...\e[0m"
    exit 1
fi

if ! gcc -ggdb -o nand_example nand_example.c libnand.so -L. -lnand; then
    echo -e "\e[31mCompilation of nand_example failed! Aborting...\e[0m"
    exit 1
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.

test_names="simple example memory"

for test in $test_names
do

    echo "Launching: $test test"
    if (($vg == 0)); then
            ./nand_example "$test" >output.out 2> output_err.out
        else
            valgrind $VG_FLAGS ./nand_example "$test" >output.out 2> output_err.out
    fi

    if (($? != 0)); then
        echo -e "\e[33mRuntime error\e[0m"
        echo "You can see logs:"
        echo "Output: $(dirname output.out)/output.out"
        echo "Errors & valgrind: $(dirname output.out)/output_err.out"
        exit 1
    else
        echo "Success"
    fi
done