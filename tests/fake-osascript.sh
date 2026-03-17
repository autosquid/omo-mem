#!/usr/bin/env bash
# Fake osascript for CI testing of notes-sync.js
set -euo pipefail

CALL_COUNTER_FILE="/tmp/omo-mem-osascript-calls"
count=$(cat "$CALL_COUNTER_FILE" 2>/dev/null || echo 0)
echo $((count + 1)) > "$CALL_COUNTER_FILE"

script="${2:-}"

if [[ "$script" == *"make new folder"* ]]; then
    echo "ok"; exit 0
fi
if [[ "$script" == *"set noteNames to"* && "$script" == *'"memory" of folder'* ]]; then
    echo ""; exit 0
fi
if [[ "$script" == *"set noteNames to"* ]]; then
    echo "SOUL.md, MEMORY.md"; exit 0
fi
if [[ "$script" == *"plaintext of"* && "$script" == *'"memory" of folder'* ]]; then
    echo "__NOT_FOUND__"; exit 0
fi
if [[ "$script" == *"plaintext of"* ]]; then
    if [[ "$script" == *'"SOUL.md"'* ]]; then
        printf '# SOUL.md\n\nTest identity content.\n'
    else
        printf '# MEMORY.md\n\nTest memory content.\n'
    fi
    exit 0
fi
if [[ "$script" == *"make new note"* || "$script" == *"set body of"* ]]; then
    echo "ok"; exit 0
fi

echo "fake-osascript: unhandled pattern: ${script:0:80}" >&2
exit 1
