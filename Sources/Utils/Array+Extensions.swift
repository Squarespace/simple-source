import Foundation

extension Array {
    subscript (safe index: Int) -> Iterator.Element? {
        return index < count ? self[index] : nil
    }
}
