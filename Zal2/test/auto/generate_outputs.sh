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

  filename="${FILE%.*}"
  outputFileName="${filename}.out"
  echo "Running assembler..."
  if ! ./mdiv_asm < "$FILE" > "$outputFileName" 2> "./mdiv_asm_err.out" ; then
    echo -e "${RED}Assembler failed${END}"
    exit 1
  fi

  echo -e "${BLUE}Success${END}"
  echo

done

echo -e "${GREEN}All generated!${END}"

exit
