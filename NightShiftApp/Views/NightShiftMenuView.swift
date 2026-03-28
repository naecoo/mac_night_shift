import Foundation
import SwiftUI

struct NightShiftMenuView: View {
    @EnvironmentObject var nightShift: NightShiftController
    @EnvironmentObject var displayManager: DisplayManager
    @State private var brightnessValues: [CGDirectDisplayID: Float] = [:]
    
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
    
    private var nightShiftToggle: some View {
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
    }
    
    private var perDisplayControls: some View {
        ForEach(displayManager.displays) { display in
            DisplayRowView(
                display: display,
                brightness: Binding(
                    get: { brightnessValues[display.displayID] ?? display.brightness },
                    set: { brightnessValues[display.displayID] = $0 }
                ),
                onBrightnessChange: { value in
                    displayManager.setBrightness(display.displayID, value: value)
                }
            )
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button("Hotkey Settings...") {
                // Open hotkey settings
            }
            
            Divider()
            
            Button("Quit NightShift") {
                NSApplication.shared.terminate(nil)
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}
