#!/usr/bin/env bash
# .tools/bin/build.sh - Build/compile the project
#
# Configure this script for your project's build system.
# Uncomment ONE of the examples below or add your own command.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/build.sh --release

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npm run build "$@"
# yarn build "$@"
# pnpm build "$@"
# npx tsc "$@"
# npx vite build "$@"

# --- Python ---
# python -m build "$@"
# pip install -e . "$@"
# poetry build "$@"

# --- Go ---
# go build ./... "$@"

# --- Rust ---
# cargo build "$@"

# --- Ruby ---
# bundle exec rake build "$@"

# --- Java/Kotlin ---
# ./gradlew build "$@"
# mvn package "$@"

# --- Elixir ---
# mix compile "$@"

# --- C/C++ ---
# make "$@"
# cmake --build build "$@"

# --- Make (generic) ---
# make build "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/build.sh is not configured for this project."
echo "Edit this file and uncomment or add your build command."
echo "See .tools/README.md for examples."
exit 1
