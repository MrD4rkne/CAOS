#!/bin/bash

# colors

RED="\e[31m"
GREEN="\e[32m"
END="\e[0m"

WORK_DIR="$PWD"
TEST_NAMES="auto manual moodle unit"
TESTS_DIR="."

TESTS_COUNT=10
VALGRIND=0

while getopts ":vn:" OPTION; do

    case "$OPTION" in
    v)
        VALGRIND=1
        ;;
    n)
        TESTS_COUNT=${OPTARG}
        ((TESTS_COUNT > 0)) || usage
        ;;
    ?)
        echo "Script usage: $(basename $0) [-v] [-n number of tests]"
        exit 1
        ;;

    esac
done

VALGRIND_OPTION=""

if [ $VALGRIND -eq 1 ]; then
    VALGRIND_OPTION="-v"
fi

echo "Auto tests count: ${TESTS_COUNT}"
echo "Valgrid: ${VALGRIND}"

echo

for test in $TEST_NAMES; do

    echo "Loading $test .."

    ./prepare.sh "$TESTS_DIR/$test"

    if ! cd "$TESTS_DIR/$test"; then
        echo -e "${RED}Folder for $test was not found.${END}"
        exit 1
    fi

    TEST_COUNT_ARG=""
    if [ "$test" = "auto" ]; then
        TEST_COUNT_ARG="-n $TESTS_COUNT"
    fi

    echo "Loaded."
    echo "Running..."

    if ! ./run_tests.sh $VALGRIND_OPTION "$TEST_COUNT_ARG" >"$WORK_DIR/${test}.out" 2>"$WORK_DIR/${test}_err.out"; then
        echo -e "${RED}Failed!${END}"
        echo "You can see outputs here:"
        echo "Standard: $WORK_DIR/${test}.out"
        echo "Error: $WORK_DIR/${test}_err.out"
        exit 1
    else
        echo -e "${GREEN}Success${END}!"
    fi

    echo

    cd "$WORK_DIR" || exit

done

exit
