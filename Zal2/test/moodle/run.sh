#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
END="\e[0m"

echo
echo "Compiling..."
echo

if ! make mdiv_example ; then
  echo -e "${RED}Compilation failed${END}"
  exit 1
fi

echo -e "${BLUE}Success${END}"

echo
echo "Running test..."
echo

if ! ./mdiv_example ; then
  exit 1
fi

exit
