
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

AK3="$ROOT/AnyKernel3"
OUT="$ROOT/out"

[[ -f "$OUT/Image" ]] || {
    echo "Missing compiled Image"
    exit 1
}

[[ -f "$ROOT/anykernel/anykernel.sh" ]] || {
    echo "Missing anykernel/anykernel.sh"
    exit 1
}

rm -rf "$AK3"

git clone --depth=1 \
    https://github.com/osm0sis/AnyKernel3.git \
    "$AK3"

cp "$ROOT/anykernel/anykernel.sh" "$AK3/anykernel.sh"
cp "$OUT/Image" "$AK3/Image"

rm -f "$AK3"/Image.gz "$AK3"/Image.gz-dtb

cd "$AK3"

zip -r9 "$OUT/AnyKernel3-POCO-F7.zip" . \
    -x ".git/*" \
       "*.md" \
       "*.txt"

cd "$OUT"

sha256sum AnyKernel3-POCO-F7.zip

echo "AnyKernel3 package created."
