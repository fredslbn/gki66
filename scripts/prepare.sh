
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL="$ROOT/kernel"

cd "$KERNEL"

echo "Kernel revision:"
git log -1 --oneline

if [[ -f "$ROOT/patches/series" ]]; then
    while IFS= read -r patch || [[ -n "$patch" ]]; do
        [[ -z "$patch" || "$patch" == \#* ]] && continue

        echo "Applying $patch"

        git apply --check "$ROOT/patches/$patch"
        git apply "$ROOT/patches/$patch"
    done < "$ROOT/patches/series"
fi

echo "Patch application complete."
git diff --stat
