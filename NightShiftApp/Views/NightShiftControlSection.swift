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
