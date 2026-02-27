#!/usr/bin/env bash
# .tools/bin/lint.sh - Run linter checks
#
# Configure this script for your project's linter(s).
# Uncomment ONE of the examples below or add your own command.
# You can chain multiple linters if needed.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/lint.sh --fix

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npx eslint . "$@"
# npx biome check . "$@"
# npm run lint "$@"

# --- Python ---
# ruff check . "$@"
# flake8 "$@"
# pylint src/ "$@"
# python -m pylint src/ "$@"

# --- Go ---
# golangci-lint run "$@"
# go vet ./... "$@"

# --- Rust ---
# cargo clippy "$@"

# --- Ruby ---
# bundle exec rubocop "$@"

# --- Java/Kotlin ---
# ./gradlew lint "$@"
# ./gradlew ktlintCheck "$@"

# --- Elixir ---
# mix credo "$@"

# --- Shell ---
# shellcheck **/*.sh "$@"

# --- Make (generic) ---
# make lint "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/lint.sh is not configured for this project."
echo "Edit this file and uncomment or add your lint command."
echo "See .tools/README.md for examples."
exit 1
