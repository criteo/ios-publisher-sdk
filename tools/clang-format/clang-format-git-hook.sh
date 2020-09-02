#!/bin/bash

# cp tools/clang-format/clang-format-git-hook.sh .git/hooks/pre-commit

format_file() {
  file="${1}"
  if [ -f "$file" ]; then
    clang-format -i "$file"
  fi
}

for file in $(git diff-index --cached --name-only HEAD | grep -iE '\.(m|h)$'); do
  format_file "${file}"
done
