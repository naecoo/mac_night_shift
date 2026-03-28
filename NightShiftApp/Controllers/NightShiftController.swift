import Foundation
import SwiftUI

class NightShiftController: ObservableObject {
    private var frameworkHandle: UnsafeMutableRawPointer?
    private var blueLightClient: AnyObject?
    @Published private(set) var isEnabled: Bool = false
    @Published private(set) var strength: Float = 0.5

    init() {
        loadStatus()
    }
    
    func toggle() {
        isEnabled.toggle()
        setEnabled(isEnabled)
    }
    
    func setEnabled(_ enabled: Bool) {
        guard let client = getBlueLightClient() else { return }

        let selector = NSSelectorFromString("setEnabled:")
        guard client.responds(to: selector) else { return }

        guard let methodIMP = client.method(for: selector) else { return }

        typealias SetEnabledFunc = @convention(c) (AnyObject, Selector, Int) -> Bool
        let setEnabled = unsafeBitCast(methodIMP, to: SetEnabledFunc.self)

        let enabledValue = enabled ? 1 : 0
        _ = setEnabled(client, selector, enabledValue)

        self.isEnabled = enabled
    }

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

    private func getBlueLightClient() -> AnyObject? {
        if let client = blueLightClient {
            return client
        }
        
        if frameworkHandle == nil {
            let frameworkPath = "/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness"
            frameworkHandle = dlopen(frameworkPath, RTLD_NOW)
            if frameworkHandle == nil {
                print("Failed to load CoreBrightness framework")
                return nil
            }
        }
        
        guard let clientClass = NSClassFromString("CBBlueLightClient") as? NSObject.Type else {
            print("Failed to find CBBlueLightClient class")
            return nil
        }
        
        let client = clientClass.init()
        blueLightClient = client
        return client
    }
    
    private func loadStatus() {
        guard let client = getBlueLightClient() else {
            isEnabled = false
            return
        }
        
        let statusSize = 48
        let statusPtr = UnsafeMutableRawPointer.allocate(
            byteCount: statusSize,
            alignment: MemoryLayout<Int>.alignment
        )
        defer { statusPtr.deallocate() }
        statusPtr.initializeMemory(as: UInt8.self, repeating: 0, count: statusSize)
        
        let selector = NSSelectorFromString("getBlueLightStatus:")
        guard client.responds(to: selector) else {
            isEnabled = false
            return
        }
        
        guard let methodIMP = client.method(for: selector) else {
            isEnabled = false
            return
        }
        
        typealias GetStatusFunc = @convention(c) (AnyObject, Selector, UnsafeMutableRawPointer) -> Bool
        let getStatus = unsafeBitCast(methodIMP, to: GetStatusFunc.self)
        
        let success = getStatus(client, selector, statusPtr)
        guard success else {
            isEnabled = false
            return
        }
        
        let enabled = statusPtr.load(fromByteOffset: 1, as: Int8.self)
        isEnabled = enabled != 0
    }

    func increaseStrength(by amount: Float = 0.1) {
        setStrength(strength + amount)
    }

    func decreaseStrength(by amount: Float = 0.1) {
        setStrength(strength - amount)
    }

    deinit {
        if let handle = frameworkHandle {
            dlclose(handle)
        }
    }
}
