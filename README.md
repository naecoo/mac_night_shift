# nightshift

A simple CLI tool and Raycast extension to control macOS Night Shift mode.

## CLI Tool

### Build

```bash
make
```

### Usage

```bash
./nightshift toggle    # Toggle Night Shift on/off
./nightshift on        # Enable Night Shift
./nightshift off       # Disable Night Shift
./nightshift status    # Show current status
```

### Zsh Alias

Add this to your `~/.zshrc`:

```bash
alias ns='/path/to/nightshift'
```

Then reload:
```bash
source ~/.zshrc
ns toggle
```

Or install to `/usr/local/bin` for global access:
```bash
make install
alias ns='nightshift'
```

## Raycast Extension

A modern Raycast extension that provides the same functionality with a native macOS experience.

### Features

- **Toggle Night Shift** - Quickly toggle Night Shift on/off
- **Turn On Night Shift** - Enable Night Shift
- **Turn Off Night Shift** - Disable Night Shift
- **Night Shift Status** - Show current Night Shift status with HUD feedback

### Installation

1. Navigate to the extension directory:
```bash
cd raycast-extension
```

2. Install dependencies:
```bash
npm install
```

3. Build the extension:
```bash
npm run build
```

4. Import into Raycast:
   - Open Raycast
   - Run `Import Extension` command
   - Select the `raycast-extension` folder

### Development

```bash
# Start development mode with hot reload
npm run dev

# Build for production
npm run build

# Run linter
npm run lint

# Fix lint issues
npm run fix-lint
```

## Requirements

- macOS 10.12.4+
- For CLI: Xcode Command Line Tools
- For Raycast extension: Raycast 1.50.0+, Node.js 18+

## License

MIT
