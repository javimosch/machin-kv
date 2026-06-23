#!/usr/bin/env bash
set -euo pipefail
MACHIN="${MACHIN:-machin}"
"$MACHIN" encode flags.src kv.src > kv.mfl
"$MACHIN" build kv.mfl -o machin-kv
echo "built ./machin-kv"
