import Cocoa

fileprivate func withEventHandle(closure: (NXEventHandle) -> Void) {
    let handle = NXOpenEventStatus()
    closure(handle)
    NXCloseEventStatus(handle)
}

/// A small abstraction over the mouse and trackpad that allows the easy
/// modification and access of their acceleration speeds.
enum HIDDevice: String {
    case mouse
    case trackpad

    fileprivate var accelerationTypeKey: String {
        get {
            switch self {
            case .mouse:
                return kIOHIDMouseAccelerationType
            case .trackpad:
                return kIOHIDTrackpadAccelerationType
            }
        }
    }

    /// The acceleration of the device.
    ///
    /// A value of -1.0 (internally 65535.0) completely disables acceleration.
    var acceleration: Double {
        get {
            var speed: Double = 0.0
            withEventHandle { handle in
                IOHIDGetAccelerationWithKey(handle, self.accelerationTypeKey as CFString, &speed)
            }
            return speed == 65535.0 ? -1.0 : speed
        }

        set {
            let value = newValue == -1.0 ? 65535.0 : newValue
            withEventHandle { handle in
                IOHIDSetAccelerationWithKey(handle, self.accelerationTypeKey as CFString, value)
            }
        }
    }
}
