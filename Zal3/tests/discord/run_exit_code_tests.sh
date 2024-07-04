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
    "Valid arguments 1" "tests/plik1" "101" 0
    "Valid arguments 2" "tests/plik1" "0000000000000000000000000000000000000000000000000000000000000000" 0 # 64 zeroes 
    "Missing arguments" "" "" 1
    "Missing 1st argument" "" "10011" 1
    "Missing 2nd argument" "plik1" "" 1
    "Too many arguments 1" "plik1 01010" "1001" 1
    "Too many arguments 2" "plik1 asfdfd" "1010" 1
    "Too many arguments 3" "plik1 10" "asdf asdf" 1
    "Invalid 2nd argument 1" "plik1" "101a0014" 1
    "Invalid 2nd argument 2" "plik1" "asbdbdffd" 1
    "Invalid 2nd argument 3" "plik1" "00000000000000000000000000000000000000000000000000000000000000000" 1 # 65 zeroes
    "Invalid 1st argument 1" "pplik1" "1010" 1
    "Invalid 1st argument 2" "11101" "1010" 1
    "Invalid 1st argument 3" "dummy" "1010" 1
    "Invalid file structure 1" "tests/plik3" "1" 1
    "Invalid file structure 2" "tests/plik4" "1" 1
)


run_test() {
    description=$1
    filename=$2
    crc=$3
    expected_exit_code=$4

    echo -ne "Test ${MAG}$description${NC}: "

        $PROGRAM_PATH $filename $crc >/dev/null
    actual_exit_code=$?

    if [ $actual_exit_code -eq $expected_exit_code ]; then
        echo -e "${GRN}Passed${NC} with exit code ${actual_exit_code}."
    else
        echo -e "${RED}Failed${NC}"
        echo "Exit code: ${actual_exit_code}, expected_exit_code: ${expected_exit_code}."
    fi
}


if ! ./compile.sh; then
    echo -e ${RED}Compliation error!${NC}
    exit 1
else
    echo -e ${GRN}Compilation successful!${NC}
fi

echo -e "Running tests..."

for ((i=0; i<${#tests[@]}; i+=4)); do
    run_test "${tests[i]}" "${tests[i+1]}" "${tests[i+2]}" "${tests[i+3]}"
done
