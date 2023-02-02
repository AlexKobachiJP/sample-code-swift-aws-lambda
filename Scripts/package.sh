#!/bin/bash

set -eu

EXECUTABLE=$1
FILE_NAME=$2
TARGET=".build/lambda/$EXECUTABLE"

rm -rf "$TARGET"
mkdir -p "$TARGET"
cp ".build/release/$EXECUTABLE" "$TARGET/"
# Use ldd to add target dependencies
ldd ".build/release/$EXECUTABLE" | grep swift | awk '{print $3}' | xargs cp -Lv -t "$TARGET"
cd "$TARGET"
ln -s "$EXECUTABLE" "bootstrap"
zip --symlinks $FILE_NAME *
