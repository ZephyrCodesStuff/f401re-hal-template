# Helper script to resolve a target alias to the canonical board folder name inside 'boards/'.

#!/usr/bin/env bash
set -euo pipefail


# Resolves a target alias (e.g. 'f401', 'g491', 'STM32F401RE') to the
# canonical board folder name inside 'boards/'.
TARGET="${1:-STM32F401RE}"

# Strip leading 'target=' if passed as a positional value (e.g. `just clean target=f401`)
TARGET="${TARGET#target=}"

# Search boards/ for a case-insensitive substring match
FOUND=$(find boards -maxdepth 1 -mindepth 1 -iname "*${TARGET}*" 2>/dev/null | head -n 1)

if [ -n "$FOUND" ]; then
    basename "$FOUND"
else
    # Fallback to the target string itself
    echo "$TARGET"
fi
