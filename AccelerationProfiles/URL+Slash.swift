import Cocoa

extension URL {
    static func /(left: URL, right: String) -> URL {
        return left.appendingPathComponent(right)
    }
}
