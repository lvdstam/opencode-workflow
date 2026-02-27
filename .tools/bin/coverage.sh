#!/usr/bin/env bash
# .tools/bin/coverage.sh - Generate test coverage report
#
# Configure this script for your project's coverage tool.
# Uncomment ONE of the examples below or add your own command.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/coverage.sh --html

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npx vitest run --coverage "$@"
# npx jest --coverage "$@"
# npx c8 npm test "$@"
# npx nyc npm test "$@"

# --- Python ---
# pytest --cov=src --cov-report=term-missing "$@"
# coverage run -m pytest "$@" && coverage report
# python -m pytest --cov "$@"

# --- Go ---
# go test -coverprofile=coverage.out ./... "$@"
# go tool cover -html=coverage.out -o coverage.html

# --- Rust ---
# cargo tarpaulin "$@"
# cargo llvm-cov "$@"

# --- Ruby ---
# bundle exec rspec --format documentation "$@"
# # (SimpleCov generates coverage automatically)

# --- Java/Kotlin ---
# ./gradlew jacocoTestReport "$@"
# mvn jacoco:report "$@"

# --- Elixir ---
# mix test --cover "$@"

# --- Make (generic) ---
# make coverage "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/coverage.sh is not configured for this project."
echo "Edit this file and uncomment or add your coverage command."
echo "See .tools/README.md for examples."
exit 1
