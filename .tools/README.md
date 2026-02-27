# Project Tools Configuration

This directory contains wrapper scripts that abstract your project's tooling from the workflow system. This allows the workflow to remain technology-agnostic while you configure the specific tools for your stack.

## Quick Setup

1. Edit each script in `.tools/bin/` for your project
2. Uncomment the appropriate command or add your own
3. Make scripts executable: `chmod +x .tools/bin/*.sh`
4. Verify with: `.tools/bin/test.sh` (should run your tests)

## Scripts

| Script | Purpose | Used By |
|--------|---------|---------|
| `test.sh` | Run tests | testing-creator, testing-reviewer |
| `build.sh` | Build/compile project | coding-creator, coding-reviewer |
| `lint.sh` | Run linter checks | coding-creator, coding-reviewer |
| `format.sh` | Auto-format code | coding-creator |
| `coverage.sh` | Generate coverage report | testing-creator, testing-reviewer |
| `install.sh` | Install dependencies | coding-creator |
| `typecheck.sh` | Run type checker | coding-creator, coding-reviewer |
| `dev.sh` | Start dev server | coding-creator |

## Configuration Examples

### JavaScript/TypeScript (npm)

```bash
# test.sh
npm test "$@"

# build.sh
npm run build "$@"

# lint.sh
npx eslint . "$@"

# format.sh
npx prettier --write . "$@"

# coverage.sh
npx vitest run --coverage "$@"

# install.sh
npm install "$@"

# typecheck.sh
npx tsc --noEmit "$@"

# dev.sh
npm run dev "$@"
```

### Python (pytest + ruff)

```bash
# test.sh
pytest "$@"

# build.sh
python -m build "$@"

# lint.sh
ruff check . "$@"

# format.sh
ruff format . "$@"

# coverage.sh
pytest --cov=src --cov-report=term-missing "$@"

# install.sh
pip install -r requirements.txt "$@"

# typecheck.sh
mypy src/ "$@"

# dev.sh
uvicorn main:app --reload "$@"
```

### Go

```bash
# test.sh
go test ./... "$@"

# build.sh
go build ./... "$@"

# lint.sh
golangci-lint run "$@"

# format.sh
gofmt -w . "$@"

# coverage.sh
go test -coverprofile=coverage.out ./... "$@"

# install.sh
go mod download "$@"

# typecheck.sh
go vet ./... "$@"

# dev.sh
go run . "$@"
```

### Rust

```bash
# test.sh
cargo test "$@"

# build.sh
cargo build "$@"

# lint.sh
cargo clippy "$@"

# format.sh
cargo fmt "$@"

# coverage.sh
cargo tarpaulin "$@"

# install.sh
cargo fetch "$@"

# typecheck.sh
cargo check "$@"

# dev.sh
cargo run "$@"
```

## Arguments

All scripts pass arguments through via `"$@"`. This means you can:

```bash
# Run specific tests
.tools/bin/test.sh tests/unit/

# Run build in release mode
.tools/bin/build.sh --release

# Check formatting without modifying
.tools/bin/format.sh --check

# Run linter with auto-fix
.tools/bin/lint.sh --fix
```

## Multiple Commands

You can chain multiple commands in a single script:

```bash
#!/usr/bin/env bash
# lint.sh - Run multiple linters
set -euo pipefail

echo "Running ESLint..."
npx eslint . "$@"

echo "Running Prettier check..."
npx prettier --check .

echo "All linters passed!"
```

## Conditional Logic

You can add environment detection if needed:

```bash
#!/usr/bin/env bash
# test.sh - Smart test runner
set -euo pipefail

if [ -f "package.json" ]; then
    npm test "$@"
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    pytest "$@"
elif [ -f "go.mod" ]; then
    go test ./... "$@"
elif [ -f "Cargo.toml" ]; then
    cargo test "$@"
else
    echo "ERROR: Could not detect project type"
    exit 1
fi
```

## Workflow Integration

The workflow system checks these scripts before starting:

1. **Pre-flight check**: Verifies which scripts are configured
2. **Warning**: Shows unconfigured scripts before proceeding
3. **Runtime**: Agents use these scripts instead of direct tool calls

If a script is not configured (contains the default error message), the workflow will warn you but allow you to proceed. Some phases may fail if required scripts are missing.

## Troubleshooting

### "Permission denied"
```bash
chmod +x .tools/bin/*.sh
```

### "Command not found"
Make sure the tool is installed and in your PATH. For project-local tools:
```bash
# JavaScript - use npx
npx eslint . "$@"

# Python - use python -m
python -m pytest "$@"
```

### Script works manually but fails in workflow
Check that:
1. Script has proper shebang: `#!/usr/bin/env bash`
2. Script uses `set -euo pipefail` for error handling
3. PATH includes necessary tools
