#!/usr/bin/env bash
# .tools/bin/typecheck.sh - Run type checking
#
# Configure this script for your project's type checker.
# Uncomment ONE of the examples below or add your own command.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/typecheck.sh --strict

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npx tsc --noEmit "$@"
# npm run typecheck "$@"
# npx vue-tsc --noEmit "$@"

# --- Python ---
# mypy src/ "$@"
# pyright "$@"
# python -m mypy . "$@"

# --- Go ---
# go vet ./... "$@"
# # Go has built-in type checking at compile time

# --- Rust ---
# cargo check "$@"
# # Rust has built-in type checking at compile time

# --- Ruby ---
# bundle exec srb tc "$@"
# # (Sorbet type checker)

# --- Java/Kotlin ---
# # Java/Kotlin have built-in type checking at compile time
# ./gradlew compileKotlin "$@"

# --- Elixir ---
# mix dialyzer "$@"

# --- Make (generic) ---
# make typecheck "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/typecheck.sh is not configured for this project."
echo "Edit this file and uncomment or add your typecheck command."
echo "See .tools/README.md for examples."
exit 1
