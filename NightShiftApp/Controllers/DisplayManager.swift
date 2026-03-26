import Foundation
import SwiftUI
import Combine

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
