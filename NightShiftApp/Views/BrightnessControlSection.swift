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
