#!/usr/bin/env bash
set -e

echo "→ justjcurtis.dev setup bootstrap"
echo "→ https://github.com/justjcurtis/setup"
echo

TMP="$(mktemp -d)"
cd "$TMP"

echo "→ Made temporary directory at $TMP"
echo "→ Here I would clone the setup repository and run its install script"

echo "→ Cleaning up..."
rm -rf "$TMP"
echo "→ Removed temporary directory"

