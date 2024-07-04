#!/bin/bash

RED="\033[31m"
GRN="\033[32m"
MAG="\033[35m"
NC="\033[0m"

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
 

for((i = 0; i < 33; i++)) {
    echo -ne "Test $i: "
   
    for((j = 0; j < ${#crc[@]}; j++)) {
        filename=tests/test${i}_${j}.out
        ../src/c/a.out tests/test$i.in ${crc[$j]} > $filename

        exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo Error. Wrong exit code $exit_code. Expected 0
        fi 
           
    }
    echo done.
}

echo All done.

