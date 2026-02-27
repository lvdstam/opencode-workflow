---
description: Initialize the .tools/ directory with wrapper script templates
---

# Initialize Tool Wrappers

Create or reset the `.tools/bin/` directory with template wrapper scripts.

## Your Tasks

1. **Check if `.tools/bin/` already exists**
   - If the directory exists with files, ask the user:
     ```
     The .tools/bin/ directory already exists with scripts.
     
     Options:
     1. Skip - Keep existing scripts (default)
     2. Overwrite - Replace all scripts with fresh templates
     3. Merge - Only create missing scripts, keep existing ones
     
     What would you like to do? [skip/overwrite/merge]
     ```
   - If directory doesn't exist, proceed with creation

2. **Create directory structure**
   ```
   .tools/
   ├── bin/
   │   ├── test.sh
   │   ├── build.sh
   │   ├── lint.sh
   │   ├── format.sh
   │   ├── coverage.sh
   │   ├── install.sh
   │   ├── typecheck.sh
   │   └── dev.sh
   └── README.md
   ```

3. **Create each script with template content**
   
   Each script should:
   - Have the shebang: `#!/usr/bin/env bash`
   - Include `set -euo pipefail`
   - Have commented examples for common tool stacks
   - End with the default error stub:
     ```bash
     echo "ERROR: .tools/bin/<script>.sh is not configured for this project."
     echo "Edit this file and uncomment or add your command."
     echo "See .tools/README.md for examples."
     exit 1
     ```

4. **Make scripts executable**
   ```bash
   chmod +x .tools/bin/*.sh
   ```

5. **Create/update .tools/README.md**
   Include documentation on:
   - What each script does
   - Example configurations for common stacks
   - How to customize scripts

6. **Inform the user**
   ```
   Created .tools/bin/ with 8 script templates:
   
     - test.sh      (run tests)
     - build.sh     (build/compile)
     - lint.sh      (run linters)
     - format.sh    (format code)
     - coverage.sh  (coverage report)
     - install.sh   (install dependencies)
     - typecheck.sh (type checking)
     - dev.sh       (dev server)
   
   Next steps:
   1. Edit each script in .tools/bin/ for your project
   2. Uncomment the command for your tech stack
   3. See .tools/README.md for detailed examples
   4. Run /workflow-start <feature> to begin development
   ```

## Script Templates

The template for each script follows this pattern:

```bash
#!/usr/bin/env bash
# .tools/bin/<name>.sh - <description>
#
# Configure this script for your project.
# Uncomment ONE of the examples below or add your own.

set -euo pipefail

# ============================================
# EXAMPLES (uncomment one or customize)
# ============================================

# --- JavaScript/TypeScript ---
# <js example>

# --- Python ---
# <python example>

# --- Go ---
# <go example>

# --- Rust ---
# <rust example>

# ============================================
# DEFAULT: Error if not configured
# ============================================
echo "ERROR: .tools/bin/<name>.sh is not configured for this project."
echo "Edit this file and uncomment or add your command."
echo "See .tools/README.md for examples."
exit 1
```

## Notes

- This command is idempotent - running it multiple times is safe
- Existing configured scripts are preserved unless user chooses "overwrite"
- The README.md in .tools/ provides comprehensive documentation
