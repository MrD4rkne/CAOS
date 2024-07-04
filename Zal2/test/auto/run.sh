#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
END="\e[0m"
PROGRAM_OUTPUT="./output.out"
PROGRAM_ERROR_OUTPUT="./errors.out"

echo "Compiling assembler..."

if ! make mdiv_asm ; then
  echo -e "${RED}Compilation failed${END}"
  exit 1
fi

echo -e "${BLUE}Success${END}"

FILES=$(find "./tests/" -type f -name "*.in")

echo
echo "Running tests..."
echo

for FILE in $FILES
do
echo "Test: $FILE"

echo "Running assembler..."
if ! time ./mdiv_asm < "$FILE" > "$PROGRAM_OUTPUT" 2> "$PROGRAM_ERROR_OUTPUT" ; then
  echo -e "${RED}Program failed${END}"
  exit 1
fi

filename="${FILE%.*}"
outputFileName="${filename}.out"

if ! diff -wq "$outputFileName" $PROGRAM_OUTPUT; then
        echo -e "${RED}Outputs differ${END}"
        exit 1
    else
        echo -e "${BLUE}OK${END}"
fi

echo

done

echo -e "${GREEN}All passed!${END}"

exit
