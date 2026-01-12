import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameResult: Comparable {
    static func < (lhs: GameResult, rhs: GameResult) -> Bool {
        
        if lhs.correct != rhs.correct {
            return lhs.correct < rhs.correct
        }
        
        let lhsAccuracy = Double(lhs.correct) / Double(lhs.total)
        let rhsAccuracy = Double(rhs.correct) / Double(rhs.total)
        return lhsAccuracy < rhsAccuracy
    }
}
