#!/bin/bash

mkdir -p temp || exit 1
COPY_TO_DIR="$PWD/temp"

cd solution || exit 1
make clean
cd "$COPY_TO_DIR" || exit

echo "Copying files to temp directory..."

cp ../solution/* "$PWD" || exit 1

echo "Removing memory tests..."
rm -rf memory_tests*

echo "Removing nand.h..."
rm -rf nand.h

# Remove old zip file
rm -rf ../solution.zip

zip -r ../solution.zip * || exit 1

echo "Cleaning up..."
rm -rf "$COPY_TO_DIR" || exit 1

exit 0