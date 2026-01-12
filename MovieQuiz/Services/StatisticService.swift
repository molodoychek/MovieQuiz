import Foundation

final class StatisticService: StatisticServiceProtocol {
    private enum Keys: String {
        case correct, total, bestGameCorrect, bestGameTotal, bestGameDate, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YY HH:mm"
        return formatter
    }()
    
    
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var totalAccuracy: Double {
        get {
            let total = userDefaults.integer(forKey: Keys.total.rawValue)
            guard total > 0 else { return 0 }
            let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
            return Double(correct) / Double(total) * 100
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = userDefaults.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = userDefaults.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = userDefaults.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            userDefaults.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            userDefaults.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            userDefaults.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    
    
    func store(correct count: Int, total amount: Int) {
        
        let currentGamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        userDefaults.set(currentGamesCount + 1, forKey: Keys.gamesCount.rawValue)
        
        let currentCorrect = userDefaults.integer(forKey: Keys.correct.rawValue)
        userDefaults.set(currentCorrect + count, forKey: Keys.correct.rawValue)
        
        let currentTotal = userDefaults.integer(forKey: Keys.total.rawValue)
        userDefaults.set(currentTotal + amount, forKey: Keys.total.rawValue)
        
        
        let currentBestCorrect = userDefaults.integer(forKey: Keys.bestGameCorrect.rawValue)
        let currentBestTotal = userDefaults.integer(forKey: Keys.bestGameTotal.rawValue)
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        let currentBestGame = GameResult(correct: currentBestCorrect,
                                         total: currentBestTotal,
                                         date: userDefaults.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date())
        
        
        if currentGame > currentBestGame {
            bestGame = currentGame
        }
    }
}
