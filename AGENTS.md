# AGENTS.md - Coding Guidelines for nightshift

## Project Overview

A simple CLI tool to control macOS Night Shift mode. Written in C, uses Objective-C runtime to interface with macOS CoreBrightness framework.

## Build Commands

```bash
# Build the project
make

# Clean build artifacts
make clean

# Install to /usr/local/bin/ (requires sudo)
make install
```

## Build Configuration

- **Compiler**: clang
- **Flags**: `-Wall -Wextra -O2 -framework Foundation`
- **Target**: Single binary `nightshift`
- **Source**: `nightshift.c`

## Code Style Guidelines

### Formatting

- **Indentation**: 4 spaces (no tabs)
- **Line endings**: Unix (LF)
- **Max line length**: 100 characters
- **Braces**: Same line (K&R style)
- **Spacing**: One space after keywords (if, for, while, return)

### Naming Conventions

- **Functions**: `snake_case` (e.g., `get_client`, `set_enabled`)
- **Static functions**: Prefix with `static` keyword
- **Struct names**: `PascalCase` with `_t` suffix avoided (use typedef directly)
- **Variables**: `snake_case`
- **Constants**: Use `#define` or `const` with `UPPER_CASE`

### Import Order

```c
#include <stdio.h>     // C standard library first
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <objc/runtime.h>  // System/framework headers after
#include <objc/message.h>
```

### Error Handling

- Print errors to `stderr` with descriptive messages
- Use `exit(1)` for fatal errors
- Check all pointer returns before dereferencing
- Always release Objective-C objects before exit

Example:
```c
if (!client) {
    fprintf(stderr, "Error: Failed to create CBBlueLightClient\n");
    exit(1);
}
```

### Memory Management

- Use `memset` to initialize structs to zero
- Release Objective-C objects with `objc_msgSend` and `sel_registerName("release")`
- No dynamic memory allocation with `malloc`/`free` in this codebase

### Type Safety

- Use explicit function pointer casts when calling Objective-C runtime
- Define structs for complex data structures (Status, Schedule, Time)
- Use `char` for boolean-like values in struct fields to match framework

## Project Structure

```
nightshift/
├── nightshift.c    # Main source file
├── Makefile        # Build configuration
└── README.md       # User documentation
```

## Testing

No automated test suite exists. Test manually:

```bash
./nightshift status    # Check current status
./nightshift on        # Enable Night Shift
./nightshift off       # Disable Night Shift
./nightshift toggle    # Toggle state
```

## Requirements

- macOS 10.12.4+
- Xcode Command Line Tools
- clang compiler

## Additional Notes

- This tool uses private macOS APIs (CoreBrightness framework)
- API may break in future macOS versions
- Code is intentionally minimal and focused
