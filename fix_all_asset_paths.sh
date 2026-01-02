#!/bin/bash
# Fix all lib/assets/ to assets/ in the lib directory
FILES=$(grep -rl "lib/assets/" lib/)
for file in $FILES; do
  echo "Fixing $file"
  sed -i .bak "s|lib/assets/|assets/|g" "$file"
  rm "${file}.bak"
done
