#!/bin/bash

TESTS_DIRECTORY="./tests"
ORIGIN_DIRECTORY="$PWD"
FILE_NAME="crc.asm"
RUN_SCRIPT_NAME="run.sh"

tests="discord"

for test in $tests
do
  test_directory="$TESTS_DIRECTORY/$test"

  if ! cp "$ORIGIN_DIRECTORY/$FILE_NAME" "$test_directory/$FILE_NAME" ; then
    echo "Could not copy source file. Aborting..."
    continue
  fi

  echo "File copied"

  if ! cd "$test_directory" ; then
    echo "Dould not navigate to test's directory. Aborting..."
    continue
  fi

  if bash "$RUN_SCRIPT_NAME" ; then
    echo "Success"
  else
    echo "Fail"
  fi

done