#!/usr/bin/env bash
# Export a clean PHP or Swift distribution package from a checked-out SDK repo.
# Does not publish, commit, create a repo, or tag anything.
set -euo pipefail
kind="${1:-}"; destination="${2:-}"
case "$kind" in php|swift) ;; *) echo "Usage: bash scripts/export-package.sh {php|swift} <new-output-directory>" >&2; exit 2;; esac
test -n "$destination" || { echo "Output directory required" >&2; exit 2; }
test ! -e "$destination" || { echo "Output directory must not exist" >&2; exit 2; }
mkdir -p "$destination"
git archive HEAD:"packages/$kind" | tar -x -C "$destination"
test -s "$destination/LICENSE"
if [[ "$kind" == php ]]; then test -s "$destination/composer.json"; else test -s "$destination/Package.swift"; fi
echo "Exported $kind into $destination; review before publishing to any external mirror."
