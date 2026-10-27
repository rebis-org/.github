#!/bin/sh
set -e
src=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
dst=${USERFONTS:-"$HOME/Library/Fonts"}
for f in lmroman10-regular.otf lmroman10-bold.otf lmmono10-regular.otf; do
  cmp -s "$src/$f" "$dst/$f" || install -m 0644 "$src/$f" "$dst/$f"
done
printf '%s\n' "fonts installed to $dst"
