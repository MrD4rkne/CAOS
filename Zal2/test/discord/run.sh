#!/bin/bash

arguments="val"

cd "./test"

for arg in $arguments
do
  echo "Running $arg"
  if ! ./tester.sh "$arg" ; then
    echo "Failed"
  else
    echo "Pass"
  fi
done