# AGENTS.md - Coding Guidelines for nightshift

## Project Overview

A simple CLI tool and Raycast extension to control macOS Night Shift mode. Written in C, uses Objective-C runtime to interface with macOS CoreBrightness private framework.

## Build Commands

```bash
make              # Build the CLI binary
make clean        # Remove build artifacts
make install      # Install to /usr/local/bin/ (requires sudo)
```

## Build Configuration

- **Compiler**: clang
- **Flags**: `-Wall -Wextra -O2 -framework Foundation`
- **Target**: Single binary `nightshift`
- **Source**: `nightshift.c`

## Raycast Extension (if present)

The project may include a Raycast extension under `raycast-extension/`. If present:

```bash
cd raycast-extension
npm install       # Install dependencies
npm run dev       # Development mode with hot reload
npm run build     # Production build
npm run lint      # Run linter
npm run fix-lint  # Auto-fix lint issues
```

## Verification After Changes

**Always verify after modifying `nightshift.c`:**

```bash
make clean && make                    # Rebuild from scratch
./nightshift status                   # Basic smoke test
./nightshift toggle                   # Verify toggle works
./nightshift                          # Verify usage message on no args
./nightshift invalid                  # Verify error handling for bad input
```

The tool requires macOS 10.12.4+ and will not run on non-macOS systems.

## Code Style Guidelines

### Formatting

- **Indentation**: 4 spaces (no tabs)
- **Line endings**: Unix (LF)
- **Max line length**: 100 characters
- **Braces**: Same line (K&R style)
- **Spacing**: One space after keywords (`if`, `for`, `while`, `return`)

### Naming Conventions

- **Functions**: `snake_case` (e.g., `get_client`, `set_enabled`)
- **Static functions**: Prefix with `static` keyword
- **Struct names**: `PascalCase` directly via typedef (avoid `_t` suffix)
- **Variables**: `snake_case`
- **Constants**: Use `#define` or `const` with `UPPER_CASE`

### Import Order

```c
#include <stdio.h>         // C standard library first
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <objc/runtime.h>  // System/framework headers after
#include <objc/message.h>
```

### Error Handling

- Print errors to `stderr` with descriptive messages
- Use `exit(1)` for fatal errors in CLI context
- Check all pointer returns before dereferencing
- Always release Objective-C objects before exit

```c
if (!client) {
    fprintf(stderr, "Error: Failed to create CBBlueLightClient\n");
    exit(1);
}
```

### Memory Management

- Use `memset` to initialize structs to zero
- Release Objective-C objects with `objc_msgSend` + `sel_registerName("release")`
- No dynamic memory allocation (`malloc`/`free`) in this codebase
- Framework handles are loaded once via `dlopen` and cached

### Type Safety

- Use explicit function pointer casts for Objective-C runtime calls
- Define structs for complex data (`Status`, `Schedule`, `Time`)
- Use `char` for boolean-like struct fields to match framework ABI

## Project Structure

```
nightshift/
├── nightshift.c            # Main CLI source (single file)
├── Makefile                # Build configuration
├── README.md               # User documentation
└── raycast-extension/      # Raycast extension (optional)
```

## Debugging Private Frameworks

This tool uses `CoreBrightness.framework` (private macOS API). When issues arise:

- **dlopen failure**: Framework path may have changed in newer macOS
- **Class not found**: Apple may have renamed `CBBlueLightClient`
- **Method signature changes**: `getBlueLightStatus:` or `setEnabled:` may have different signatures
- Check `dlerror()` output for framework loading issues
- Test on the target macOS version; private APIs break between major releases

## Git Conventions

- Commit messages: imperative mood, concise (e.g., "Add toggle command", "Fix status output")
- Include `[skip ci]` in commit message if changes are docs-only
- Run `make clean && make` before committing code changes
- Do not commit the `nightshift` binary (it's in `.gitignore`)

## Testing

No automated test suite. Manual verification:

```bash
./nightshift status    # Check current status
./nightshift on        # Enable Night Shift
./nightshift off       # Disable Night Shift
./nightshift toggle    # Toggle state
./nightshift           # Shows usage (no args = exit 1)
./nightshift bad       # Shows error + usage (invalid = exit 1)
```

## Requirements

- macOS 10.12.4+
- Xcode Command Line Tools
- clang compiler

## Key Constraints

- Uses private macOS APIs — may break in future macOS versions
- Code is intentionally minimal and focused (single source file)
- No external dependencies beyond system frameworks
- Raycast extension requires Raycast 1.50.0+ and Node.js 18+
