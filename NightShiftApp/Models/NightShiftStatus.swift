import Foundation

struct NightShiftStatus {
    var active: Int8
    var enabled: Int8
    var sunSchedulePermitted: Int8
    var mode: Int8
    var schedule: Schedule
    var disableFlags: UInt64
    var available: Int8
}

struct Schedule {
    var fromTime: Time
    var toTime: Time
}

struct Time {
    var hour: Int32
    var minute: Int32
}
