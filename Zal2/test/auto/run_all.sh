#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
END="\e[0m"

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

if ! time ./mdiv_asm < "$FILE" > "./mdiv_asm.out" 2> "./mdiv_asm_err.out" ; then
  echo -e "${RED}Assembler failed${END}"
  exit 1
fi

echo -e "${BLUE}Success${END}"

echo "Running test program..."

if ! dotnet run --project ./auto/ < "$FILE" > "./mdiv_auto.out" 2> "./mdiv_auto_err.out" ; then
  echo -e "${RED}Auto failed${END}"
  exit 1
fi

echo -e "${BLUE}Success${END}"

if ! diff -wq ./mdiv_auto.out ./mdiv_asm.out; then
        echo -e "${RED}Outputs differ${END}"
        exit 1
    else
        echo -e "${GREEN}OK${END}"
fi

echo

done

echo -e "${GREEN}All passed!${END}"

exit
