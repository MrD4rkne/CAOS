#!/bin/bash

RED="\033[31m"
GRN="\033[32m"
MAG="\033[35m"
NC="\033[0m"

if ! ./compile.sh; then
    echo -e "${RED}Compliation error.${NC}"
    exit
else
    echo -e "${GRN}Compiled successfully.${NC}"
fi

crc=(
                                                                  1
                                                                  0
                                                                 00
                                                                 01
                                                                 10
                                                                 11
                                                                011 #
                                                           11010101 # 
                                   10100010001000111010001101111100 # 32
                                   00001101111111011110001000001011 # 32
   0010001010001110010100001011100101001110001110101101010100111011 # 64
   1111111111111111111111111111111111111111111111111111111111111111 # 64

)
 

for((i = 1; i < 33; i++)) {
    echo -ne "Test $i: "

    if ! test -f tests/test$i.in; then
        echo file tests/test$i.in missing. Try running python3 gen.py.
        continue
    fi
   
    total_runtime=0

    correct=1
    for((j = 0; j < ${#crc[@]}; j++)) {
        asm_out=$(mktemp)

        start=$(date +%s%N) 
        ./crc tests/test$i.in ${crc[$j]} &> $asm_out
        exit_code=$?
        end=$(date +%s%N)
        total_runtime=$(($total_runtime+$end-$start))
        if [ $exit_code -ne 0 ]; then
            echo -e "${RED}Wrong exit code.${NC}"
            echo -e "Expected: 0, got: $exit_code."
            correct=0
            break
        fi

        if ! diff -q $asm_out tests/test${i}_${j}.out >/dev/null; then
            echo -e "${RED}Wrong answer.${NC}"
            echo -e "CRC polynomial: ${crc[$j]}."
            echo -e "Expected answer:"
            cat  tests/test${i}_${j}.out
            echo -e "Actual answer:"
            cat $asm_out
            correct=0
            break
        fi
           
    }

    if [ $correct -eq 1 ]; then
        avg_runtime=$((total_runtime / ${#crc[@]} / 1000000))
        echo -e "${GRN}Passed.${NC} Average execution time: $avg_runtime ms."
    fi
    
}

