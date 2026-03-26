import Foundation
import AppKit
import CoreGraphics

struct DisplayInfo: Identifiable {
    let id = UUID()
    let displayID: CGDirectDisplayID
    let name: String
    var brightness: Float
    
    static var allDisplays: [DisplayInfo] {
        let screens = NSScreen.screens
        var displays: [DisplayInfo] = []
        
        for screen in screens {
            guard let displayID = screen.displayID else { continue }
            
            var brightness: Float = 0.5
            
            displays.append(DisplayInfo(
                displayID: displayID,
                name: screen.localizedName ?? "Unknown Display",
                brightness: brightness
            ))
        }
        
        return displays
    }
    
    func setBrightness(_ value: Float) {
        let setBrightness = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "CGDisplaySetBrightness")
        typealias SetBrightnessFunc = @convention(c) (CGDirectDisplayID, Float) -> Int32
        let function = unsafeBitCast(setBrightness, to: SetBrightnessFunc.self)
        _ = function(displayID, value)
    }
    
    static var mainDisplay: CGDirectDisplayID {
        CGMainDisplayID()
    }
}

extension NSScreen {
    var displayID: CGDirectDisplayID? {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }
    
    var localizedName: String? {
        deviceDescription[NSDeviceDescriptionKey("NSDeviceName")] as? String
    }
}
