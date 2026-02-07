# Night Shift Control for Raycast

Control macOS Night Shift mode directly from Raycast.

## Commands

- **Toggle Night Shift** - Toggle Night Shift on/off
- **Turn on Night Shift** - Enable Night Shift
- **Turn off Night Shift** - Disable Night Shift
- **Night Shift Status** - Show current Night Shift status

## Requirements

- macOS 10.12.4+
- Raycast 1.50.0+
- Node.js 18+

## Installation

### Local Development

1. Clone this repository
2. Navigate to the extension directory:
   ```bash
   cd raycast-extension
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Run in development mode:
   ```bash
   npm run dev
   ```
5. Build for production:
   ```bash
   npm run build
   ```

### Import into Raycast

1. Open Raycast
2. Run `Import Extension` command
3. Select the `raycast-extension` folder

## Publishing to Raycast Store

Before publishing, update the following in `package.json`:

1. Change `"author": "your-username"` to your actual Raycast username
2. Optionally update the icon in `assets/icon.png` (512x512 PNG)
3. Run `npm run publish` to submit to the Raycast Store

## Development

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

## How It Works

This extension uses Python with the CoreBrightness framework to control Night Shift:
- `CBBlueLightClient` class from CoreBrightness framework
- Python's `objc` module to interface with Objective-C runtime
- HUD notifications for user feedback
