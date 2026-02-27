#!/usr/bin/env bash
# .tools/bin/test.sh - Run project tests
#
# Configure this script for your project's test runner.
# Uncomment ONE of the examples below or add your own command.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/test.sh --verbose

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npm test "$@"
# yarn test "$@"
# pnpm test "$@"
# npx vitest run "$@"
# npx jest "$@"

# --- Python ---
# pytest "$@"
# python -m pytest "$@"
# python -m unittest discover "$@"

# --- Go ---
# go test ./... "$@"

# --- Rust ---
# cargo test "$@"

# --- Ruby ---
# bundle exec rspec "$@"
# bundle exec rake test "$@"

# --- Java/Kotlin ---
# ./gradlew test "$@"
# mvn test "$@"

# --- Elixir ---
# mix test "$@"

# --- Make (generic) ---
# make test "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/test.sh is not configured for this project."
echo "Edit this file and uncomment or add your test command."
echo "See .tools/README.md for examples."
exit 1
