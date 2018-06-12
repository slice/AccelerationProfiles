import Cocoa

enum PointerDevice: String {
    case mouse
    case trackpad
    
    var accelerationType: String {
        get {
            switch self {
            case .mouse:
                return kIOHIDMouseAccelerationType
            case .trackpad:
                return kIOHIDTrackpadAccelerationType
            }
        }
    }
    
    var speed: Double {
        get {
            var speed: Double = 0
            let handle = NXOpenEventStatus()
            IOHIDGetAccelerationWithKey(
                handle,
                self.accelerationType as CFString,
                &speed
            )
            NXCloseEventStatus(handle)
            return speed
        }

        set {
            let handle = NXOpenEventStatus()
            IOHIDSetAccelerationWithKey(
                handle,
                self.accelerationType as CFString,
                newValue
            )
            NXCloseEventStatus(handle)
        }
    }
}
