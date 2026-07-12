#!/usr/bin/env bash

set -euo pipefail

src="$(readlink -f "$(command -v swhkd)")"
dst="/usr/local/bin/swhkd"

if cmp -s "$src" "$dst"; then
  echo "$dst is already up to date"
  exit 0
fi

sudo install -o root -g root -m 4755 "$src" "$dst"
echo "installed $src -> $dst (setuid root)"
