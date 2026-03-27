# Better Display Design Specification

**Date:** 2026-03-27
**Project:** NightShift / Better Display
**Scope:** Display brightness and color temperature (Night Shift) control for macOS

## Overview

A simplified Better Display application for macOS that provides display brightness and Night Shift (color temperature) control with multi-monitor support and keyboard shortcuts. The app runs as a menu bar application with SwiftUI interface.

## System Architecture

### Overall Architecture

The application follows MVVM pattern with reactive data flow using SwiftUI's `@Published` and `@ObservedObject`.

```
┌─────────────────────────────────────────────┐
│           AppDelegate (Entry Point)         │
│   - Initialize all controllers               │
│   - Manage status bar menu                   │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│NightShift    │ │Display   │ │Hot            │
│Controller    │ │Manager   │ │Manager       │
│  - Toggle     │ │  - Bright│ │  - Hotkey    │
│  - Strength   │ │    - Multi│ │    - Register│
│  - Adjust     │ │    - Set  │ │    - Handle  │
└──────────────┘ └──────────┘ └──────────────┘
        │                              │
        ▼                              ▼
┌──────────────────┐          ┌──────────────────┐
│SwiftUI Views    │          │System Callbacks │
│  - Menu Interface│          │  - Hotkey Trigger│
│  - Display Rows  │          └──────────────────┘
└──────────────────┘
```

## Component Design

### 1. NightShiftController

**Purpose:** Control Night Shift toggle and intensity adjustment using CoreBrightness framework.

**Interface:**

```swift
class NightShiftController: ObservableObject {
    @Published private(set) var isEnabled: Bool = false
    @Published private(set) var strength: Float = 0.5

    // Existing functionality
    func toggle()
    func setEnabled(_ enabled: Bool)

    // New functionality
    func setStrength(_ strength: Float)  // Set intensity 0.0-1.0
    func increaseStrength(by amount: Float = 0.1)  // Increase intensity
    func decreaseStrength(by amount: Float = 0.1)  // Decrease intensity
    func toggleAndAdjust()  // Quick shortcut: enable with default strength if disabled
}
```

**Implementation Details:**

- Uses `CoreBrightness` framework private APIs
- `CBBlueLightClient` for system interaction
- `setEnabled:` for toggle control
- `setStrength:` for intensity adjustment (0.0 = no effect, 1.0 = maximum effect)
- Strength range: 0.0 to 1.0 (mapped to system's internal range)

---

### 2. DisplayManager

**Purpose:** Manage brightness control for multiple displays using CGDisplay APIs.

**Interface:**

```swift
class DisplayManager: ObservableObject {
    @Published var displays: [DisplayInfo] = []

    // Existing functionality
    func refreshDisplays()
    func setBrightness(_ displayID: CGDirectDisplayID, value: Float)

    // New functionality
    func increaseBrightness(_ displayID: CGDirectDisplayID, by amount: Float = 0.1)
    func decreaseBrightness(_ displayID: CGDirectDisplayID, by amount: Float = 0.1)
    func increaseAllBrightness(by amount: Float = 0.1)  // All displays
    func decreaseAllBrightness(by amount: Float = 0.1)
}
```

**Implementation Details:**

- Uses `CGDisplaySetBrightness()` to set brightness
- Uses `CGDisplayGetBrightness()` to read current brightness
- Brightness range: 0.0 to 1.0 (0% to 100%)
- Monitors display connection/disconnection via `DistributedNotificationCenter`
- Auto-refreshes display list on application activation

---

### 3. HotkeyManager

**Purpose:** Register and handle global keyboard shortcuts using Carbon API.

**Hotkey Mappings:**

| Action | Shortcut | Handler |
|--------|----------|---------|
| Toggle Night Shift | Cmd+Shift+N | NightShiftController.toggle() |
| Increase Brightness | Cmd+Shift+↑ | DisplayManager.increaseAllBrightness() |
| Decrease Brightness | Cmd+Shift+↓ | DisplayManager.decreaseAllBrightness() |
| Increase Night Shift Strength | Cmd+Shift+← | NightShiftController.increaseStrength() |
| Decrease Night Shift Strength | Cmd+Shift+→ | NightShiftController.decreaseStrength() |

**Implementation Details:**

- Uses Carbon `RegisterEventHotKey()` and `InstallEventHandler()`
- Command key: `cmdKey`, Shift key: `shiftKey`
- Arrow keys: `kVK_UpArrow`, `kVK_DownArrow`, `kVK_LeftArrow`, `kVK_RightArrow`
- All hotkeys work globally (app doesn't need focus)

---

### 4. SwiftUI Views

#### NightShiftMenuView (Main Menu)

```swift
struct NightShiftMenuView: View {
    @EnvironmentObject var nightShift: NightShiftController
    @EnvironmentObject var displayManager: DisplayManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            nightShiftControlSection
            Divider()
            brightnessControlSection
            Divider()
            hotkeyHintSection
            Divider()
            settingsSection
        }
        .padding()
        .frame(width: 320)
    }
}
```

#### NightShiftControlSection

```swift
struct NightShiftControlSection: View {
    @ObservedObject var nightShift: NightShiftController

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Toggle switch
            Toggle(isOn: Binding(...)) {
                HStack {
                    Image(systemName: "moon.fill")
                    Text("Night Shift")
                }
            }

            // Strength slider (shown when enabled)
            if nightShift.isEnabled {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strength")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(
                        value: $nightShift.strength,
                        in: 0...1
                    )
                }
                .padding(.leading, 24)
            }
        }
    }
}
```

#### BrightnessControlSection

```swift
struct BrightnessControlSection: View {
    @ObservedObject var displayManager: DisplayManager

    var body: some View {
        ForEach(displayManager.displays) { display in
            VStack(alignment: .leading, spacing: 6) {
                // Display name
                HStack {
                    Image(systemName: "display")
                    Text(display.name)
                        .fontWeight(.medium)
                    Spacer()
                }

                // Brightness slider
                Slider(
                    value: Binding(...),
                    in: 0...1
                )
            }
        }
    }
}
```

#### HotkeyHintSection

```swift
struct HotkeyHintSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hotkeys")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                hotkeyRow("Toggle Night Shift", "⌘⇧N")
                hotkeyRow("Adjust Brightness", "⌘⇧↑↓")
                hotkeyRow("Adjust Night Shift", "⌘⇧←→")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
    }

    private func hotkeyRow(_ action: String, _ keys: String) -> some View {
        HStack {
            Text(action)
            Spacer()
            Text(keys)
                .font(.system(.caption2, design: .monospaced))
        }
    }
}
```

## Data Flow

### User Interaction Flow

```
User presses hotkey
    ↓
HotkeyManager receives event via Carbon callback
    ↓
HotkeyManager calls appropriate controller method
    ↓
Controller updates @Published property + calls system API
    ↓
@Published triggers notification to subscribers
    ↓
SwiftUI View receives update and automatically re-renders
    ↓
Menu bar interface reflects new state
```

### Example: Increase Brightness Flow

1. User presses Cmd+Shift+↑
2. HotkeyManager captures hotkey, calls `displayManager.increaseAllBrightness()`
3. DisplayManager:
   - Iterates through all active displays
   - Gets current brightness via `CGDisplayGetBrightness()`
   - Calculates new brightness (adds 0.1, clamped to 0.0-1.0)
   - Sets new brightness via `CGDisplaySetBrightness()`
   - Calls `refreshDisplays()` to update state
4. `displays` property update triggers SwiftUI re-render
5. All `DisplayRowView` components update with new slider positions

## Error Handling

### Strategy: Silent Failures + Logging

This is a background utility tool. Errors should not interrupt user experience but should be logged for debugging.

### Error Types and Handling

#### 1. Permission Errors

**Screen Recording Permission (required for brightness control):**

- On app launch, check `CGPreflightScreenCaptureAccess()`
- If not granted, show prompt with `CGRequestScreenCaptureAccess()`
- Display permission warning in settings section if permission denied
- Continue with limited functionality (Night Shift still works)

#### 2. API Call Failures

**CoreBrightness failures:**

- Silent failure - don't show alerts
- Log to console: `print("Failed to set Night Shift strength: \(error)")`
- Keep last known state

**Display API failures:**

- Silent failure for individual displays
- Log to console with display ID
- Continue operation on other displays
- Example:
  ```swift
  guard CGDisplaySetBrightness(displayID, brightness) == .success else {
      print("Failed to set brightness for display \(displayID)")
      return
  }
  ```

#### 3. Display Connection/Disconnection

**Hot-plug handling:**

- Monitor via `DistributedNotificationCenter`
- On disconnection: remove from `displays` array
- On connection: add to `displays` array, call `refreshDisplays()`
- Handle gracefully without app restart required

### Example Error Handling Implementation

```swift
func increaseBrightness(_ displayID: CGDirectDisplayID, by amount: Float) {
    guard displays.contains(where: { $0.displayID == displayID }) else {
        print("Display \(displayID) not found")
        return
    }

    var brightness = CGDisplayGetBrightness(displayID)
    brightness = min(1.0, max(0.0, brightness + amount))

    guard CGDisplaySetBrightness(displayID, brightness) == .success else {
        print("Failed to set brightness for display \(displayID)")
        return
    }

    refreshDisplays()
}
```

## Permissions and Requirements

### System Permissions

1. **Screen Recording** (Required for brightness control)
   - Required: `CGPreflightScreenCaptureAccess()`
   - Request: `CGRequestScreenCaptureAccess()`
   - System prompt on first use

2. **Accessibility** (May be required for hotkeys)
   - Optional depending on macOS version
   - Request if hotkeys fail

### System Requirements

- macOS 10.12.4+ (for Night Shift support)
- Xcode 14+ (for SwiftUI and modern Swift)
- Swift 5.7+

### Frameworks Used

- `SwiftUI` - UI framework
- `AppKit` - Menu bar and status item
- `CoreGraphics` - Display brightness API
- `Carbon` - Hotkey registration
- `CoreBrightness` - Night Shift control (private framework)

## File Structure

```
NightShiftApp/
├── NightShiftApp.swift          # App entry point and AppDelegate
├── Package.swift                # Swift Package Manager config
├── Controllers/
│   ├── NightShiftController.swift   # Night Shift control
│   ├── DisplayManager.swift        # Display brightness management
│   └── HotkeyManager.swift          # Global hotkey handling
├── Views/
│   ├── NightShiftMenuView.swift     # Main menu view
│   ├── NightShiftControlSection.swift # Night Shift controls
│   ├── BrightnessControlSection.swift  # Brightness controls
│   └── HotkeyHintSection.swift      # Hotkey hints
├── Models/
│   ├── DisplayInfo.swift            # Display data model
│   └── NightShiftStatus.swift       # Night Shift status model
└── Services/
    └── PermissionChecker.swift      # System permission checking
```

## Testing Strategy

### Unit Tests

- Test NightShiftController state transitions
- Test DisplayManager brightness calculations
- Test hotkey parsing and command mapping

### Integration Tests

- Test display detection on multi-monitor systems
- Test hotkey registration and triggering
- Test permission request flows

### Manual Testing

- Test on macOS 12, 13, 14, 15
- Test with 1, 2, and 3+ displays
- Test display hot-plug (connect/disconnect)
- Test all hotkey combinations
- Test permission denial scenarios
- Test app startup on login

## Performance Considerations

### Optimization Points

1. **Debounce slider events** - Don't update brightness on every fractional slide
2. **Limit refresh frequency** - Don't poll displays excessively
3. **Use efficient timer** - 1-second interval for status icon updates (existing)
4. **Lazy view updates** - SwiftUI only updates changed components

### Memory Management

- Use `weak self` in closures to prevent retain cycles
- Properly clean up Carbon hotkey registrations on deinit
- Unload CoreBrightness framework on deinit (existing)

## Future Enhancements (Out of Scope)

- Preset brightness profiles (e.g., Day/Night modes)
- Display-specific Night Shift settings
- Color picker for custom tint
- Automatic schedule (time-based switching)
- Full color temperature control (beyond Night Shift range)
- External display DDC/CI hardware control

## Success Criteria

The implementation is successful when:

1. ✅ Night Shift can be toggled on/off
2. ✅ Night Shift strength can be adjusted via slider (0-100%)
3. ✅ Brightness can be adjusted per display via slider
4. ✅ All displays are detected and shown
5. ✅ All 5 hotkeys work globally
6. ✅ Changes persist during app session
7. ✅ No error alerts shown to user
8. ✅ App runs stable without crashes
9. ✅ Permission requests work correctly
10. ✅ Menu bar UI is responsive and usable

## Implementation Notes

### Private Framework Access

`CoreBrightness` is a private framework. Access requires:
- Dynamic loading with `dlopen()`
- Runtime method resolution with `NSSelectorFromString`
- Unsafe bitcasting for method signatures
- This is standard practice for Night Shift control apps

### Carbon Hotkey Deprecation

Carbon API is deprecated but still required for global hotkeys in macOS:
- Alternative: `NSEvent` with `addGlobalMonitorForEvents` (requires Accessibility)
- Carbon approach used for broader compatibility without Accessibility permission

### Display Brightness API Notes

- `CGDisplaySetBrightness()` sets system brightness level
- Some external displays may not support software brightness control
- Internal displays (built-in screens) always supported
- Brightness may be overridden by system ambient light sensors

---

**Document Version:** 1.0
**Last Updated:** 2026-03-27
**Status:** Ready for Implementation Plan
