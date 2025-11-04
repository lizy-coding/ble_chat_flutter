#!/usr/bin/env bash
set -e
echo "[melos] bootstrap..."
melos bootstrap
echo "[melos] build_runner for all packages..."
melos run gen
echo "done."
