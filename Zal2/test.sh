#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
END="\e[0m"

tests="moodle auto discord"
pwd="$PWD"

for test in $tests
do
  echo "$test"
  cp mdiv.asm ./test/$test/ || exit
  cd test/$test || exit

  if ! bash ./run.sh ; then
    echo -e "${RED}Test failed${END}"
  else
    echo -e "${GREEN}Success${END}"
  fi

  cd "$pwd" || exit
done


echo -e "${GREEN}Passed${END}"
exit
