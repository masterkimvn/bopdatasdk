#!/usr/bin/env bash
# Read the catalog, or pass a canonical ID to retrieve its JSON representation.
set -euo pipefail
base='https://data.bop.ink/api/v1/datasets'
if [ "$#" -eq 0 ]; then
  curl --fail --silent --show-error --max-time 10 "$base.json"
elif [ "$#" -eq 1 ] && [[ "$1" =~ ^[A-Za-z0-9._-]{3,}$ ]]; then
  curl --fail --silent --show-error --max-time 10 "$base/$1.json"
else
  printf '%s\n' 'Usage: dataset.sh [canonical-id]' >&2
  exit 2
fi
