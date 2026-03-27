# Better Display Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add display brightness control and Night Shift strength adjustment features to the existing NightShift menu bar application with multi-monitor support and global hotkeys.

**Architecture:** MVVM pattern with reactive data flow using SwiftUI's @Published and @ObservedObject. Extends existing NightShiftController, DisplayManager, and HotkeyManager with new functionality and creates new SwiftUI view components.

**Tech Stack:** Swift 5.7+, SwiftUI, AppKit, CoreGraphics, Carbon, CoreBrightness (private framework)

---

## File Structure

```
NightShiftApp/
├── Controllers/
│   ├── NightShiftController.swift   # Add: strength control methods
│   ├── DisplayManager.swift        # Add: brightness increase/decrease methods
│   └── HotkeyManager.swift          # Add: new hotkey registrations
├── Views/
│   ├── NightShiftMenuView.swift     # Update: integrate new sections
│   ├── NightShiftControlSection.swift # Create: Night Shift toggle + strength slider
│   ├── BrightnessControlSection.swift  # Create: display brightness sliders
│   └── HotkeyHintSection.swift      # Create: hotkey reference UI
└── Services/
    └── PermissionChecker.swift      # Create: screen recording permission check
```

---

### Task 1: Add Night Shift strength property to NightShiftController

**Files:**
- Modify: `NightShiftApp/Controllers/NightShiftController.swift:5-7`

- [ ] **Step 1: Add strength property**

Modify the class to add a new `@Published` property for strength control:

```swift
class NightShiftController: ObservableObject {
    private var frameworkHandle: UnsafeMutableRawPointer?
    private var blueLightClient: AnyObject?
    @Published private(set) var isEnabled: Bool = false
    @Published private(set) var strength: Float = 0.5  // Add this line

    init() {
        loadStatus()
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/NightShiftController.swift
git commit -m "feat: add strength property to NightShiftController"
```

---

### Task 2: Add setStrength method to NightShiftController

**Files:**
- Modify: `NightShiftApp/Controllers/NightShiftController.swift:14-16`

- [ ] **Step 1: Add setStrength method**

Add method to set Night Shift strength:

```swift
    func setStrength(_ strength: Float) {
        let clampedStrength = max(0.0, min(1.0, strength))
        guard let client = getBlueLightClient() else { return }

        let selector = NSSelectorFromString("setStrength:")
        guard client.responds(to: selector) else { return }

        guard let methodIMP = client.method(for: selector) else { return }

        typealias SetStrengthFunc = @convention(c) (AnyObject, Selector, Float) -> Bool
        let setStrength = unsafeBitCast(methodIMP, to: SetStrengthFunc.self)

        let success = setStrength(client, selector, clampedStrength)
        if success {
            self.strength = clampedStrength
        } else {
            print("Failed to set Night Shift strength to \(clampedStrength)")
        }
    }
```

Add this after the `setEnabled` method.

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/NightShiftController.swift
git commit -m "feat: add setStrength method to NightShiftController"
```

---

### Task 3: Add increaseStrength method to NightShiftController

**Files:**
- Modify: `NightShiftApp/Controllers/NightShiftController.swift:102`

- [ ] **Step 1: Add increaseStrength method**

```swift
    func increaseStrength(by amount: Float = 0.1) {
        setStrength(strength + amount)
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/NightShiftController.swift
git commit -m "feat: add increaseStrength method to NightShiftController"
```

---

### Task 4: Add decreaseStrength method to NightShiftController

**Files:**
- Modify: `NightShiftApp/Controllers/NightShiftController.swift:106`

- [ ] **Step 1: Add decreaseStrength method**

```swift
    func decreaseStrength(by amount: Float = 0.1) {
        setStrength(strength - amount)
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/NightShiftController.swift
git commit -m "feat: add decreaseStrength method to NightShiftController"
```

---

### Task 5: Add increaseBrightness method to DisplayManager

**Files:**
- Modify: `NightShiftApp/Controllers/DisplayManager.swift:24`

- [ ] **Step 1: Add increaseBrightness method**

```swift
    func increaseBrightness(_ displayID: CGDirectDisplayID, by amount: Float = 0.1) {
        guard let display = displays.first(where: { $0.displayID == displayID }) else {
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

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/DisplayManager.swift
git commit -m "feat: add increaseBrightness method to DisplayManager"
```

---

### Task 6: Add decreaseBrightness method to DisplayManager

**Files:**
- Modify: `NightShiftApp/Controllers/DisplayManager.swift:39`

- [ ] **Step 1: Add decreaseBrightness method**

```swift
    func decreaseBrightness(_ displayID: CGDirectDisplayID, by amount: Float = 0.1) {
        guard let display = displays.first(where: { $0.displayID == displayID }) else {
            print("Display \(displayID) not found")
            return
        }

        var brightness = CGDisplayGetBrightness(displayID)
        brightness = min(1.0, max(0.0, brightness - amount))

        guard CGDisplaySetBrightness(displayID, brightness) == .success else {
            print("Failed to set brightness for display \(displayID)")
            return
        }

        refreshDisplays()
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/DisplayManager.swift
git commit -m "feat: add decreaseBrightness method to DisplayManager"
```

---

### Task 7: Add increaseAllBrightness method to DisplayManager

**Files:**
- Modify: `NightShiftApp/Controllers/DisplayManager.swift:54`

- [ ] **Step 1: Add increaseAllBrightness method**

```swift
    func increaseAllBrightness(by amount: Float = 0.1) {
        for display in displays {
            increaseBrightness(display.displayID, by: amount)
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/DisplayManager.swift
git commit -m "feat: add increaseAllBrightness method to DisplayManager"
```

---

### Task 8: Add decreaseAllBrightness method to DisplayManager

**Files:**
- Modify: `NightShiftApp/Controllers/DisplayManager.swift:60`

- [ ] **Step 1: Add decreaseAllBrightness method**

```swift
    func decreaseAllBrightness(by amount: Float = 0.1) {
        for display in displays {
            decreaseBrightness(display.displayID, by: amount)
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Controllers/DisplayManager.swift
git commit -m "feat: add decreaseAllBrightness method to DisplayManager"
```

---

### Task 9: Read existing HotkeyManager to understand structure

**Files:**
- Read: `NightShiftApp/Services/HotkeyManager.swift`

- [ ] **Step 1: Read HotkeyManager**

Read the file to understand the current hotkey registration structure.

- [ ] **Step 2: No commit needed**

This is just a research step.

---

### Task 10: Add brightness increase hotkey to HotkeyManager

**Files:**
- Modify: `NightShiftApp/Services/HotkeyManager.swift`

- [ ] **Step 1: Add Cmd+Shift+↑ hotkey for increase brightness**

Add the hotkey registration and handler in the `setupHotkeys` method or similar:

```swift
func setupHotkeys() {
    // ... existing hotkeys ...

    // Add brightness increase hotkey
    registerHotkey(keyCode: UInt32(kVK_UpArrow), modifiers: UInt32(cmdKey | shiftKey)) {
        self.displayManager.increaseAllBrightness(by: 0.1)
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Services/HotkeyManager.swift
git commit -m "feat: add Cmd+Shift+↑ hotkey for brightness increase"
```

---

### Task 11: Add brightness decrease hotkey to HotkeyManager

**Files:**
- Modify: `NightShiftApp/Services/HotkeyManager.swift`

- [ ] **Step 1: Add Cmd+Shift+↓ hotkey for decrease brightness**

```swift
func setup() {
    // ... existing hotkeys ...

    // Add brightness decrease hotkey
    registerHotkey(keyCode: UInt32(kVK_DownArrow), modifiers: UInt32(cmdKey | shiftKey)) {
        self.displayManager.decreaseAllBrightness(by: 0.1)
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Services/HotkeyManager.swift
git commit -m "feat: add Cmd+Shift+↓ hotkey for brightness decrease"
```

---

### Task 12: Add Night Shift strength increase hotkey to HotkeyManager

**Files:**
- Modify: `NightShiftApp/Services/HotkeyManager.swift`

- [ ] **Step 1: Add Cmd+Shift+← hotkey for strength increase**

```swift
func setup() {
    // ... existing hotkeys ...

    // Add Night Shift strength increase hotkey
    registerHotkey(keyCode: UInt32(kVK_LeftArrow), modifiers: UInt32(cmdKey | shiftKey)) {
        self.nightShift.increaseStrength(by: 0.1)
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Services/HotkeyManager.swift
git commit -m "feat: add Cmd+Shift+← hotkey for Night Shift strength increase"
```

---

### Task 13: Add Night Shift strength decrease hotkey to HotkeyManager

**Files:**
- Modify: `NightShiftApp/Services/HotkeyManager.swift`

- [ ] **Step 1: Add Cmd+Shift+→ hotkey for strength decrease**

```swift
func setup() {
    // ... existing hotkeys ...

    // Add Night Shift strength decrease hotkey
    registerHotkey(keyCode: UInt32(kVK_RightArrow), modifiers: UInt32(cmdKey | shiftKey)) {
        self.nightShift.decreaseStrength(by: 0.1)
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Services/HotkeyManager.swift
git commit -m "feat: add Cmd+Shift+→ hotkey for Night Shift strength decrease"
```

---

### Task 14: Create NightShiftControlSection view

**Files:**
- Create: `NightShiftApp/Views/NightShiftControlSection.swift`

- [ ] **Step 1: Create NightShiftControlSection.swift file**

```swift
import SwiftUI

struct NightShiftControlSection: View {
    @ObservedObject var nightShift: NightShiftController

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: Binding(
                get: { nightShift.isEnabled },
                set: { _ in nightShift.toggle() }
            )) {
                HStack(spacing: 8) {
                    Image(systemName: nightShift.isEnabled ? "moon.fill" : "moon")
                        .foregroundColor(nightShift.isEnabled ? .orange : .secondary)
                    Text("Night Shift")
                        .fontWeight(.medium)
                }
            }

            if nightShift.isEnabled {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strength")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(
                        value: Binding(
                            get: { nightShift.strength },
                            set: { nightShift.setStrength($0) }
                        ),
                        in: 0...1
                    )
                }
                .padding(.leading, 24)
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Views/NightShiftControlSection.swift
git commit -m "feat: create NightShiftControlSection view"
```

---

### Task 15: Create BrightnessControlSection view

**Files:**
- Create: `NightShiftApp/Views/BrightnessControlSection.swift`

- [ ] **Step 1: Create BrightnessControlSection.swift file**

```swift
import SwiftUI

struct BrightnessControlSection: View {
    @ObservedObject var displayManager: DisplayManager
    @State private var brightnessValues: [CGDirectDisplayID: Float] = [:]

    var body: some View {
        ForEach(displayManager.displays) { display in
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "display")
                        .foregroundColor(.secondary)
                    Text(display.name)
                        .fontWeight(.medium)
                    Spacer()
                }

                Slider(
                    value: Binding(
                        get: { brightnessValues[display.displayID] ?? display.brightness },
                        set: { value in
                            brightnessValues[display.displayID] = value
                            displayManager.setBrightness(display.displayID, value: value)
                        }
                    ),
                    in: 0...1
                )
            }
            .id(display.displayID)
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Views/BrightnessControlSection.swift
git commit -m "feat: create BrightnessControlSection view"
```

---

### Task 16: Create HotkeyHintSection view

**Files:**
- Create: `NightShiftApp/Views/HotkeyHintSection.swift`

- [ ] **Step 1: Create HotkeyHintSection.swift file**

```swift
import SwiftUI

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

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Views/HotkeyHintSection.swift
git commit -m "feat: create HotkeyHintSection view"
```

---

### Task 17: Update NightShiftMenuView to use new sections

**Files:**
- Modify: `NightShiftApp/Views/NightShiftMenuView.swift:10-22`

- [ ] **Step 1: Update NightShiftMenuView body**

Replace the entire body with new layout:

```swift
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NightShiftControlSection(nightShift: nightShift)

            if !displayManager.displays.isEmpty {
                Divider()
                BrightnessControlSection(displayManager: displayManager)
            }

            Divider()
            HotkeyHintSection()

            Divider()
            settingsSection
        }
        .padding()
        .frame(width: 320)
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Views/NightShiftMenuView.swift
git commit -m "refactor: update NightShiftMenuView with new sections"
```

---

### Task 18: Create PermissionChecker service

**Files:**
- Create: `NightShiftApp/Services/PermissionChecker.swift`

- [ ] **Step 1: Create PermissionChecker.swift file**

```swift
import Foundation
import CoreGraphics

class PermissionChecker {
    static func hasScreenRecordingPermission() -> Bool {
        return CGPreflightScreenCaptureAccess()
    }

    static func requestScreenRecordingPermission() {
        CGRequestScreenCaptureAccess()
    }

    static var permissionStatusText: String {
        if hasScreenRecordingPermission() {
            return "Permissions OK"
        } else {
            return "Screen Recording Permission Required"
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Services/PermissionChecker.swift
git commit -m "feat: create PermissionChecker service"
```

---

### Task 19: Update settingsSection to show permission status

**Files:**
- Modify: `NightShiftApp/Views/NightShiftMenuView.swift:54-68`

- [ ] **Step 1: Update settingsSection view**

```swift
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !PermissionChecker.hasScreenRecordingPermission() {
                Button("Request Screen Recording Permission") {
                    PermissionChecker.requestScreenRecordingPermission()
                }
                .font(.caption)
            }

            Divider()

            Button("Quit NightShift") {
                NSApplication.shared.terminate(nil)
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/Views/NightShiftMenuView.swift
git commit -m "feat: add permission request to settings section"
```

---

### Task 20: Add permission check to AppDelegate on launch

**Files:**
- Modify: `NightShiftApp/NightShiftApp.swift:20-28`

- [ ] **Step 1: Add permission check in applicationDidFinishLaunching**

```swift
    func() {
        NSApp.setActivationPolicy(.accessory)

        // Check and request screen recording permission if needed
        if !PermissionChecker.hasScreenRecordingPermission() {
            // Don't request immediately, let user click in menu
            print("Screen recording permission not granted")
        }

        nightShift = NightShiftController()
        displayManager = DisplayManager()
        hotkeyManager = HotkeyManager(nightShift: nightShift, displayManager: displayManager)

        setupStatusBar()
    }
```

- [ ] **Step 2: Commit**

```bash
git add NightShiftApp/NightShiftApp.swift
git commit -m "feat: add permission check to AppDelegate launch"
```

---

### Task 21: Build and test the application

**Files:**
- Build: All Swift files

- [ ] **Step 1: Build the application**

```bash
cd NightShiftApp
swift build
```

Expected output: Build completes successfully with no errors.

- [ ] **Step 2: Run the application**

```bash
swift run
```

Expected output: Menu bar icon appears, menu can be opened.

- [ ] **Step 3: No commit needed**

This is a testing step. If build fails, fix errors before committing any subsequent changes.

---

### Task 22: Update README with new features

**Files:**
- Modify: `README.md:1-10`

- [ ] **Step 1: Update README description**

Update the README to reflect new Better Display features:

```markdown
# nightshift

A Better Display alternative for macOS - control display brightness and Night Shift with multi-monitor support and global hotkeys.

## Features

- **Night Shift Control**
  - Toggle Night Shift on/off
  - Adjust Night Shift strength (0-100%)

- **Brightness Control**
  - Per-display brightness adjustment
  - Multi-monitor support

- **Global Hotkeys**
  - ⌘⇧N: Toggle Night Shift
  - ⌘⇧↑/↓: Increase/Decrease brightness (all displays)
  - ⌘⇧←/→: Increase/Decrease Night Shift strength

## CLI Tool (Legacy)

...
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README with Better Display features"
```

---

### Task 23: Manual testing checklist

**Files:**
- Test: All functionality

- [ ] **Step 1: Test Night Shift toggle**

1. Click the menu bar icon
2. Toggle Night Shift on
3. Verify slider appears
4. Toggle Night Shift off
5. Verify slider disappears

- [ ] **Step 2: Test Night Shift strength slider**

1. Enable Night Shift
2. Drag strength slider to various positions
3. Verify visual change on screen
4. Try extreme values (0%, 50%, 100%)

- [ ] **Step 3: Test brightness sliders**

1. For each connected display, adjust the brightness slider
2. Verify brightness changes
3. Test with multiple displays

- [ ] **Step 4: Test hotkeys**

1. Press ⌘⇧N - verify Night Shift toggles
2. Press ⌘⇧↑ - verify brightness increases
3. Press ⌘⇧↓ - verify brightness decreases
4. Enable Night Shift, then press ⌘⇧← - verify strength increases
5. Press ⌘⇧→ - verify strength decreases

- [ ] **Step 5: Test permissions**

1. Deny screen recording permission
2. Verify app still launches
3. Verify "Request Screen Recording Permission" button appears
4. Click button and grant permission
5. Verify brightness controls now work

- [ ] **Step 6: No commit needed**

This is manual testing. Fix any issues found before proceeding.

---

### Task 24: Final verification and commit

**Files:**
- Verify: All changes

- [ ] **Step 1: Verify all changes are committed**

```bash
git status
```

Expected: No uncommitted changes except maybe build artifacts.

- [ ] **Step 2: Create summary commit**

```bash
git commit --allow-empty -m "feat: complete Better Display implementation

- Add Night Shift strength control
- Add per-display brightness control
- Add global hotkeys for brightness and strength adjustment
- Add new SwiftUI view components
- Add permission checking for screen recording
- Update menu bar UI with new controls"
```

- [ ] **Step 3: Tag the release**

```bash
git tag -a v2.0.0 -m "Better Display features: brightness + Night Shift strength control"
```

---

## Implementation Complete

All tasks completed! The Better Display features are now fully implemented with:

1. ✅ Night Shift toggle and strength control
2. ✅ Per-display brightness control with multi-monitor support
3. ✅ Global hotkeys for all functions
4. ✅ Modern SwiftUI menu bar interface
5. ✅ Permission handling for screen recording
6. ✅ Hotkey reference in menu

Ready for testing and distribution.
