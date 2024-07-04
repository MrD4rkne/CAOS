#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
END="\e[0m"

COUNT=10
MIN_N=1
MAX_N=10
TEMP_FILE="./temp.txt"

if [ $# -lt 1 ]; then
  echo -e "${RED}Usage: $(basename $0) <file> (count) (min_n) (max_n)${END}"
  exit 1
fi

FILE_NAME="$1"

if [ $# -gt 1 ]; then
  COUNT="$2"
fi

if [ $# -gt 2 ]; then
  MIN_N="$3"
fi

if [ $# -gt 3 ]; then
  MAX_N="$4"
fi

echo "$COUNT $MIN_N $MAX_N" > "$TEMP_FILE" || exit 1
if ! dotnet run --project ./generator/ < "$TEMP_FILE" "$COUNT $MIN_N $MAX_N"> "$FILE_NAME"; then
  echo -e "${RED}Generator failed${END}"
  exit 1
fi

	rm -rf temp.txt *.o

echo -e "${GREEN}Success${END}"