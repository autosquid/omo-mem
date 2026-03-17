#!/usr/bin/env bash

set -euo pipefail

REPO="${OMO_MEM_REPO:-autosquid/omo-mem}"
REQUESTED_VERSION="${OMO_MEM_VERSION:-latest}"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

fetch_url() {
  local url="$1"
  if has_cmd curl; then
    curl -fsSL "$url"
  elif has_cmd wget; then
    wget -qO- "$url"
  else
    echo "Error: need curl or wget to install omo-mem" >&2
    exit 1
  fi
}

parse_latest_tag() {
  local json="$1"
  if has_cmd python3; then
    python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("tag_name", ""))' "$json"
  elif has_cmd jq; then
    printf '%s' "$json" | jq -r '.tag_name // ""'
  else
    printf '%s' "$json" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1
  fi
}

resolve_version() {
  if [ "$REQUESTED_VERSION" != "latest" ]; then
    printf '%s' "$REQUESTED_VERSION"
    return 0
  fi

  local api_url="https://api.github.com/repos/${REPO}/releases/latest"
  local release_json
  if ! release_json="$(fetch_url "$api_url" 2>/dev/null)"; then
    echo "Warning: failed to resolve latest release; falling back to master" >&2
    printf 'master'
    return 0
  fi

  local tag
  tag="$(printf '%s' "$release_json" | parse_latest_tag)"
  if [ -z "$tag" ] || [ "$tag" = "null" ]; then
    echo "Warning: no release tag found; falling back to master" >&2
    printf 'master'
    return 0
  fi

  printf '%s' "$tag"
}

VERSION="$(resolve_version)"
INIT_URL="https://raw.githubusercontent.com/${REPO}/${VERSION}/init.sh"

echo "Installing omo-mem from ${REPO}@${VERSION}..."

TMP_INIT="$(mktemp)"
trap 'rm -f "$TMP_INIT"' EXIT
fetch_url "$INIT_URL" > "$TMP_INIT"
chmod +x "$TMP_INIT"

export OMO_MEM_VERSION_RESOLVED="$VERSION"
bash "$TMP_INIT"
