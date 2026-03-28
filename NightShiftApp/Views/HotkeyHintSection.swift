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
