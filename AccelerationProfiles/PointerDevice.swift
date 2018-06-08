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
            IOHIDGetAccelerationWithKey(
                NXOpenEventStatus(),
                self.accelerationType as CFString,
                &speed
            )
            return speed
        }

        set {
            IOHIDSetAccelerationWithKey(
                NXOpenEventStatus(),
                self.accelerationType as CFString,
                newValue
            )
        }
    }
}
