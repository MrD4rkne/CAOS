#!/bin/bash

tests="moodle auto"
pwd="$PWD"

for test in $tests
do
  cd test/$test || exit

  ./clean.sh

  cd "$pwd" || exit
done