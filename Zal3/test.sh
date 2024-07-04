#!/bin/bash

RED="\033[31m"
GRN="\033[32m"
MAG="\033[35m"
NC="\033[0m"

PROGRAM_PATH="./crc"
TESTS_PATH="tests"


# Tests that only check the exit code of the program.
# Format: Test description, 1st argument, 2nd argument, expected exit code.
tests=(
    "Valid" "tests/plik1" "1" 0 "1"
    "Valid" "tests/plik1" "011" 0 "010"
    "Valid" "tests/plik1" "11010101" 0 "01010111"
    "Invalidfilename" "./tests/plik" "1" 1 " "
    "Invalidpolynomial" "./tests/plik1" "" 1 " "
)

run_test() {
    description=$1
    filename=$2
    crc=$3
    expected_exit_code=$4
    expected_output=$5

    echo -ne "Test ${MAG}$description${NC}: "
    echo "$description $filename $crc $expected_exit_code $expected_output"

    $PROGRAM_PATH $filename $crc >.temp_output
    actual_exit_code=$?
    output=$(cat .temp_output)

    if [ $actual_exit_code -eq $expected_exit_code ]; then
        if [ $actual_exit_code -eq 0 ] && [ "$output" -ne "$expected_output" ]; then
            echo -e "${RED}Failed${NC}"
            echo "Output: $output, expected_output: $expected_output."
        fi
        echo -e "${GRN}Passed${NC} with exit code ${actual_exit_code}."
    else
        echo -e "${RED}Failed${NC}"
        echo "Exit code: ${actual_exit_code}, expected_exit_code: ${expected_exit_code}."
    fi

    rm -f .temp_output
}

if ! bash ./compile.sh; then
    echo -e ${RED}Compliation error!${NC}
    exit 1
else
    echo -e ${GRN}Compilation successful!${NC}
fi

echo -e "Running tests..."

for ((i=0; i<${#tests[@]}; i+=5)); do
    run_test "${tests[i]}" "${tests[i+1]}" "${tests[i+2]}" "${tests[i+3]}" "${tests[i+4]}"
done
