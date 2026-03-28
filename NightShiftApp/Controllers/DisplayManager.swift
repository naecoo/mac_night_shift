import Foundation
import SwiftUI
import Combine
import CoreGraphics

class DisplayManager: ObservableObject {
    @Published var displays: [DisplayInfo] = []
    
    init() {
        refreshDisplays()
        startDisplayMonitoring()
    }
    
    func refreshDisplays() {
        displays = DisplayInfo.allDisplays
    }
    
    func setBrightness(_ displayID: CGDirectDisplayID, value: Float) {
        guard let display = displays.first(where: { $0.displayID == displayID }) else {
            return
        }

        display.setBrightness(value)
        refreshDisplays()
    }

    func increaseBrightness(_ displayID: CGDirectDisplayID, by amount: Float = 0.1) {
        guard let display = displays.first(where: { $0.displayID == displayID }) else {
            print("Display \(displayID) not found")
            return
        }

        var brightness = display.brightness
        brightness = min(1.0, max(0.0, brightness + amount))

        display.setBrightness(brightness)
        refreshDisplays()
    }

    private func startDisplayMonitoring() {
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("NSApplicationDidBecomeActive"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshDisplays()
        }
    }
}
