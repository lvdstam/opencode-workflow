#!/usr/bin/env bash
# .tools/bin/install.sh - Install project dependencies
#
# Configure this script for your project's package manager.
# Uncomment ONE of the examples below or add your own command.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/install.sh --dev

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npm install "$@"
# npm ci "$@"
# yarn install "$@"
# pnpm install "$@"
# bun install "$@"

# --- Python ---
# pip install -r requirements.txt "$@"
# pip install -e ".[dev]" "$@"
# poetry install "$@"
# pdm install "$@"
# uv pip install -r requirements.txt "$@"

# --- Go ---
# go mod download "$@"
# go mod tidy "$@"

# --- Rust ---
# cargo fetch "$@"

# --- Ruby ---
# bundle install "$@"

# --- Java/Kotlin ---
# ./gradlew dependencies "$@"
# mvn dependency:resolve "$@"

# --- Elixir ---
# mix deps.get "$@"

# --- Make (generic) ---
# make install "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/install.sh is not configured for this project."
echo "Edit this file and uncomment or add your install command."
echo "See .tools/README.md for examples."
exit 1
