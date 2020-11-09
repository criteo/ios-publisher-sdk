#!/bin/bash

# cp tools/code-format-git-hook.sh .git/hooks/pre-commit

format_objc() {
  file="${1}"
  if [ -f "$file" ]; then
    ./tools/clang-format/clang-format -i "$file"
  fi
}

format_swift() {
  file="${1}"
  if [ -f "$file" ]; then
    swift-format -i "$file"
    swiftlint autocorrect "$file"
  fi
}

for file in $(git diff-index --cached --name-only HEAD | grep -iE '\.(m|h)$'); do
  format_objc "${file}"
done

for file in $(git diff-index --cached --name-only HEAD | grep -iE '\.(swift)$'); do
  format_swift "${file}"
done
