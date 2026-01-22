import Foundation

extension Array {
    func safe(at index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
