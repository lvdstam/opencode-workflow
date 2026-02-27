#!/usr/bin/env bash
# .tools/bin/dev.sh - Start development server
#
# Configure this script for your project's dev server.
# Uncomment ONE of the examples below or add your own command.
#
# All arguments are passed through via "$@"
# Example: .tools/bin/dev.sh --port 3000

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# npm run dev "$@"
# yarn dev "$@"
# pnpm dev "$@"
# npx vite "$@"
# npx next dev "$@"

# --- Python ---
# flask run "$@"
# uvicorn main:app --reload "$@"
# python manage.py runserver "$@"
# python -m http.server "$@"

# --- Go ---
# go run . "$@"
# air "$@"  # Hot reload

# --- Rust ---
# cargo run "$@"
# cargo watch -x run "$@"

# --- Ruby ---
# bundle exec rails server "$@"
# bundle exec puma "$@"

# --- Java/Kotlin ---
# ./gradlew bootRun "$@"
# mvn spring-boot:run "$@"

# --- Elixir ---
# mix phx.server "$@"
# iex -S mix "$@"

# --- Make (generic) ---
# make dev "$@"

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/dev.sh is not configured for this project."
echo "Edit this file and uncomment or add your dev server command."
echo "See .tools/README.md for examples."
exit 1
