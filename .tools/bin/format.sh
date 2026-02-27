#!/usr/bin/env bash
# .tools/bin/format.sh - Auto-format code
#
# Configure this script for your project's code formatter.
# Uncomment ONE of the examples below or add your own command.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/format.sh --check

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npx prettier --write . "$@"
# npx biome format --write . "$@"
# npm run format "$@"

# --- Python ---
# black . "$@"
# ruff format . "$@"
# yapf -r -i . "$@"

# --- Go ---
# gofmt -w . "$@"
# goimports -w . "$@"

# --- Rust ---
# cargo fmt "$@"

# --- Ruby ---
# bundle exec rubocop -A "$@"

# --- Java/Kotlin ---
# ./gradlew ktlintFormat "$@"
# ./gradlew spotlessApply "$@"

# --- Elixir ---
# mix format "$@"

# --- C/C++ ---
# clang-format -i **/*.{c,cpp,h,hpp} "$@"

# --- Make (generic) ---
# make format "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/format.sh is not configured for this project."
echo "Edit this file and uncomment or add your format command."
echo "See .tools/README.md for examples."
exit 1
