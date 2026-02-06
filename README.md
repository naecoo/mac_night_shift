# nightshift

A simple CLI tool to control macOS Night Shift mode.

## Build

```bash
make
```

## Usage

```bash
./nightshift toggle    # Toggle Night Shift on/off
./nightshift on        # Enable Night Shift
./nightshift off       # Disable Night Shift
./nightshift status    # Show current status
```

## Zsh Alias

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

## Requirements

- macOS 10.12.4+
- Xcode Command Line Tools

## License

MIT