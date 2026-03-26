import Foundation
import SwiftUI

struct DisplayRowView: View {
    let display: DisplayInfo
    @Binding var brightness: Float
    let onBrightnessChange: (Float) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(display.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack(spacing: 8) {
                Image(systemName: "sun.min")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Slider(value: $brightness, in: 0...1)
                    .onChange(of: brightness) { _, newValue in
                        onBrightnessChange(newValue)
                    }
                
                Image(systemName: "sun.max")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
