import Foundation
import SwiftUI
import Carbon

class HotkeyManager: ObservableObject {
    private var hotKeyRefs: [EventHotKeyRef] = []
    private let nightShift: NightShiftController
    private let displayManager: DisplayManager
    
    init(nightShift: NightShiftController, displayManager: DisplayManager) {
        self.nightShift = nightShift
        self.displayManager = displayManager
        registerDefaultHotkeys()
    }
    
    func registerDefaultHotkeys() {
        registerHotkey(keyCode: UInt32(kVK_ANSI_N), modifiers: UInt32(cmdKey | shiftKey), action: toggleNightShift)
        registerHotkey(keyCode: UInt32(kVK_ANSI_B), modifiers: UInt32(cmdKey | shiftKey), action: adjustBrightnessUp)
        registerHotkey(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | shiftKey), action: adjustBrightnessDown)
        registerHotkey(keyCode: UInt32(kVK_UpArrow), modifiers: UInt32(cmdKey | shiftKey)) {
            self.displayManager.increaseAllBrightness(by: 0.1)
        }
    }
    
    func registerHotkey(keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        let hotKeyID = EventHotKeyID(signature: OSType(0x4A4B4C4D), id: UInt32(hotKeyRefs.count + 1))
        
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr, let ref = hotKeyRef {
            hotKeyRefs.append(ref)
        }
    }
    
    private func toggleNightShift() {
        DispatchQueue.main.async {
            self.nightShift.toggle()
        }
    }
    
    private func adjustBrightnessUp() {
        DispatchQueue.main.async {
            guard let mainDisplay = self.displayManager.displays.first(where: { $0.displayID == DisplayInfo.mainDisplay }) else {
                return
            }
            
            let newBrightness = min(mainDisplay.brightness + 0.1, 1.0)
            self.displayManager.setBrightness(mainDisplay.displayID, value: newBrightness)
        }
    }
    
    private func adjustBrightnessDown() {
        DispatchQueue.main.async {
            guard let mainDisplay = self.displayManager.displays.first(where: { $0.displayID == DisplayInfo.mainDisplay }) else {
                return
            }
            
            let newBrightness = max(mainDisplay.brightness - 0.1, 0.0)
            self.displayManager.setBrightness(mainDisplay.displayID, value: newBrightness)
        }
    }
    
    deinit {
        for ref in hotKeyRefs {
            UnregisterEventHotKey(ref)
        }
    }
}
