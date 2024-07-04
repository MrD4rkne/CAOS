#!/bin/bash

rm -r ./temp
mkdir -p temp || exit 1

cp run.sh temp || exit 1
cp clean.sh temp || exit 1
cp makefile temp || exit 1
cp mediator.c temp || exit 1
cp -r tests temp || exit 1 

cp -r README.MD temp || exit 1 

rm -r tests.zip

zip -r tests.zip temp || exit 1
rm -r ./temp
echo "Success"