#!/bin/bash

CURR_DIR="$PWD"

if [ $# -ge 2 ] ; then
  SOLUTION_DIR="$1"
  DESTINATION_DIR="$2"
fi

cd "$SOLUTION_DIR" || exit 1
make clean

cd "$CURR_DIR" || exit 1

cd "$DESTINATION_DIR" || exit 1

echo "Copying..."
cp -R "$SOLUTION_DIR/." "./" || exit 1

exit 0