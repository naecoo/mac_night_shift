import Foundation
import CoreGraphics

class PermissionChecker {
    static func hasScreenRecordingPermission() -> Bool {
        return CGPreflightScreenCaptureAccess()
    }

    static func requestScreenRecordingPermission() {
        CGRequestScreenCaptureAccess()
    }

    static var permissionStatusText: String {
        if hasScreenRecordingPermission() {
            return "Permissions OK"
        } else {
            return "Screen Recording Permission Required"
        }
    }
}
