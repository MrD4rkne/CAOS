#!/bin/bash
WORK_DIR="$PWD"
TESTS_DIR="$PWD/tests"
TEST_NAMES="manual moodle unit"
SOLUTION_DIR="./solution"

FILES="$(ls $SOLUTION_DIR/)" || exit

for test in $TEST_NAMES
do
  test_dir="$TESTS_DIR/$test"
  echo 
  cd "$test_dir" || exit 1
  echo "$test:"

  echo "Make clean..."
  make clean 2> /dev/null

  echo "Remove outputs"
  rm -f ./*.out

  for file in $FILES
  do
    currFileName="$(basename "$file")"
    rm "$currFileName" 2> /dev/null
  done

  if [ -f "./clean" ] ; then
    ./clean
  fi

  cd "$WORK_DIR" || exit 1
done

rm -f ./*.out

echo
echo "Finished"
exit 