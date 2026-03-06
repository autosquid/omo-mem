#!/usr/bin/env bash
# deploy-plugin.sh — Rebuild and deploy the omo-mem plugin bundle
#
# Run this after editing plugin/omo-mem.js to push changes to opencode.
# Usage: ./deploy-plugin.sh

set -e

OMO_MEM_DIR="${OMO_MEM_DIR:-$HOME/workspace/omo-mem}"
OPENCODE_PLUGINS_DIR="$HOME/.config/opencode/plugins"
SRC="$OMO_MEM_DIR/plugin/omo-mem.js"
DEST="$OPENCODE_PLUGINS_DIR/omo-mem.js"
TEMP="$HOME/.config/opencode/_omo-mem-src.js"

if ! command -v bun &> /dev/null; then
  echo "Error: bun is required to bundle the plugin"
  exit 1
fi

mkdir -p "$OPENCODE_PLUGINS_DIR"

echo "Building plugin bundle from $SRC..."

# Copy source to config dir temporarily so bun can resolve @opencode-ai/plugin
cp "$SRC" "$TEMP"
bun build "$TEMP" \
  --outfile "$DEST" \
  --target bun \
  --external "fs/promises" \
  --external "path" \
  --external "os"
rm -f "$TEMP"

echo "✓ Deployed bundle to $DEST"
echo "  Restart opencode for changes to take effect."
