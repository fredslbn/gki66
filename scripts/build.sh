
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL="$ROOT/kernel"

: "${BAZEL_TARGET:?Set BAZEL_TARGET to an existing Kleaf kernel target}"

cd "$KERNEL"

# Validate the Kleaf environment.
if [[ ! -x tools/bazel ]]; then
    echo "ERROR: tools/bazel is missing."
    echo "This checkout is not yet a complete Kleaf workspace."
    exit 1
fi

if [[ ! -f BUILD.bazel && ! -f WORKSPACE && ! -f MODULE.bazel ]]; then
    echo "ERROR: Bazel workspace definitions are missing."
    exit 1
fi

echo "Checking target: $BAZEL_TARGET"

tools/bazel query "$BAZEL_TARGET"

echo "Starting ARM64 kernel build..."

tools/bazel build "$BAZEL_TARGET"

echo "Locating compiled Image..."

mapfile -t IMAGES < <(
    tools/bazel cquery "$BAZEL_TARGET" --output=files |
    grep -E '(^|/)Image$' || true
)

if [[ "${#IMAGES[@]}" -eq 0 ]]; then
    echo "ERROR: Target did not expose an Image output."
    exit 1
fi

if [[ "${#IMAGES[@]}" -ne 1 ]]; then
    echo "ERROR: Multiple Image outputs found:"
    printf '%s\n' "${IMAGES[@]}"
    exit 1
fi

mkdir -p "$ROOT/out"

cp -L "${IMAGES[0]}" "$ROOT/out/Image"

echo "Kernel build successful."
file "$ROOT/out/Image"
sha256sum "$ROOT/out/Image"
