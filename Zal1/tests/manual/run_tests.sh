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

if ! gcc -ggdb -o testy testy.c libnand.so -L. -lnand; then
    echo -e "\e[31mCompilation of testy failed! Aborting...\e[0m"
    exit 1
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
    
if (($vg == 0)); then
        ./testy
    else
        valgrind $VG_FLAGS ./testy
fi
    
if (($? != 0)); then
    echo -e "\e[33mRuntime error\e[0m"
    exit 1
fi