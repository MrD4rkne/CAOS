#!/bin/bash

RED="\033[31m"
GRN="\033[32m"
MAG="\033[35m"
NC="\033[0m"

crc=(1 011 11010101 1 011 11010101)
outs=(1 010 01010111 1 111 10110011)

if ! ./compile.sh; then
    echo Compilation error.
    exit 1
fi

my_out=$(mktemp) # File for out output.
c_out=$(mktemp)  # File for correct output.

for((i = 0; i < 6; i++)) {
    echo -n "Sample $i: "
    filepath=tests/plik$((i/3+1))
    if ! test -f $filepath; then
        echo File $filepath is missing.
        continue
    fi
    ./crc $filepath ${crc[$i]} >$my_out
    echo "${outs[$i]}" >$c_out

    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Wrong exit code.${NC}"
        continue
    fi

    if diff -q $c_out $my_out; then
        echo -e "${GRN}Passed.${NC}"
    else
        echo -e "${RED}Wrong answer.${NC}"
        echo "Expected:"
        cat $c_out
        echo "Got:"
        cat $my_out
    fi
    
}

args=("plik" "1" "tests/plik1" "\"\"") 


for((i = 0; i < 2; i++)) {
    j=$((i+6))
    echo -n "Sample $j: "

    ./crc ${args[$((i*2))]} ${args[$((i*2+1))]}
    exit_code=$?
    if [ $exit_code -ne 1 ]; then
        echo -e "${RED}Wrong exit code.${NC}"
        echo "Expected: 1, got: $exit_code."
        continue
    else
        echo -e "${GRN}Passed.${NC}"
    fi
}
