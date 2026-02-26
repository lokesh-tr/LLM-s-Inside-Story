import SwiftUI

class GameState: ObservableObject {
    
    @Published var totalScore: Int = 0
    @Published var moduleScores: [Int: Int] = [:] 
    @Published var miniGameScores: [Int: Int] = [:] 
    @Published var currentModule: Int = 1
    @Published var completedModules: Set<Int> = []
    @Published var completedMiniGames: Set<Int> = []
    
    
    
    static let correctAnswerScore = 10
    static let incorrectAnswerPenalty = -5
    static let miniGameCompletionScore = 50
    static let perfectModuleBonus = 25
    
    
    static let moduleMaxScores: [Int: Int] = [
        2: 100, 
        3: 100, 
        4: 100, 
        5: 100, 
        6: 100  
    ]
    
    
    
    
    
    
    
    func updateModuleScore(points: Int, forModule module: Int) {
        let currentScore = moduleScores[module] ?? 0
        let newScore = max(0, currentScore + points)
        moduleScores[module] = newScore
        updateTotalScore()
    }
    
    
    
    func completeModule(_ module: Int) {
        completedModules.insert(module)
        
        
        if let currentScore = moduleScores[module],
           let maxScore = Self.moduleMaxScores[module],
           currentScore >= maxScore {
            moduleScores[module] = currentScore + Self.perfectModuleBonus
        }
        
        updateTotalScore()
    }
    
    
    
    func completeMiniGame(_ gameNumber: Int) {
        completedMiniGames.insert(gameNumber)
        miniGameScores[gameNumber] = Self.miniGameCompletionScore
        updateTotalScore()
    }
    
    
    private func updateTotalScore() {
        let modulesTotal = moduleScores.values.reduce(0, +)
        let miniGamesTotal = miniGameScores.values.reduce(0, +)
        totalScore = modulesTotal + miniGamesTotal
    }
    
    
    var hasCompletedAllModules: Bool {
        Set(2...6).isSubset(of: completedModules)
    }
    
    
    var hasCompletedAllMiniGames: Bool {
        Set(1...4).isSubset(of: completedMiniGames)
    }
    
    
    var overallProgress: Double {
        let totalSteps = 9.0 
        let completedSteps = Double(completedModules.count + completedMiniGames.count)
        return (completedSteps / totalSteps) * 100
    }
} 