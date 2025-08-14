//
//  ScoreManager.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation

struct GameScore {
    let gameType: GameType
    let score: Int
    let playerName: String
    let isAIGame: Bool
    let difficulty: AIDifficulty?
    let date: Date
    let duration: TimeInterval?
    let metadata: [String: Any]
    
    init(gameType: GameType, score: Int, playerName: String, isAIGame: Bool = false, difficulty: AIDifficulty? = nil, duration: TimeInterval? = nil, metadata: [String: Any] = [:]) {
        self.gameType = gameType
        self.score = score
        self.playerName = playerName
        self.isAIGame = isAIGame
        self.difficulty = difficulty
        self.date = Date()
        self.duration = duration
        self.metadata = metadata
    }
}

struct LeaderboardEntry: Codable {
    let rank: Int
    let playerName: String
    let score: Int
    let gameType: String
    let date: Date
    let isAIGame: Bool
    let difficulty: String?
    
    init(rank: Int, gameScore: GameScore) {
        self.rank = rank
        self.playerName = gameScore.playerName
        self.score = gameScore.score
        self.gameType = gameScore.gameType.rawValue
        self.date = gameScore.date
        self.isAIGame = gameScore.isAIGame
        self.difficulty = gameScore.difficulty?.rawValue
    }
}

class ScoreManager {
    static let shared = ScoreManager()
    
    private var scores: [GameType: [GameScore]] = [:]
    private let maxScoresPerGame = 100 // Keep only top 100 scores per game
    
    private init() {
        loadScores()
    }
    
    // MARK: - Score Recording
    func recordScore(_ gameScore: GameScore) {
        if scores[gameScore.gameType] == nil {
            scores[gameScore.gameType] = []
        }
        
        scores[gameScore.gameType]?.append(gameScore)
        
        // Sort scores in descending order
        scores[gameScore.gameType]?.sort { $0.score > $1.score }
        
        // Keep only top scores
        if let count = scores[gameScore.gameType]?.count, count > maxScoresPerGame {
            scores[gameScore.gameType] = Array(scores[gameScore.gameType]!.prefix(maxScoresPerGame))
        }
        
        saveScores()
        
        // Check for achievements
        checkScoreAchievements(gameScore)
        
        // Update high score manager for compatibility
        updateHighScoreManager(gameScore)
    }
    
    func recordTicTacToeGame(won: Bool, vsAI: Bool, difficulty: AIDifficulty? = nil) {
        let score = won ? 100 : 0
        let gameScore = GameScore(
            gameType: .ticTacToe,
            score: score,
            playerName: UserManager.shared.currentUser?.username ?? "Player",
            isAIGame: vsAI,
            difficulty: difficulty,
            metadata: ["won": won]
        )
        recordScore(gameScore)
    }
    
    func recordConnectFourGame(won: Bool, vsAI: Bool, difficulty: AIDifficulty? = nil) {
        let score = won ? 100 : 0
        let gameScore = GameScore(
            gameType: .connectFour,
            score: score,
            playerName: UserManager.shared.currentUser?.username ?? "Player",
            isAIGame: vsAI,
            difficulty: difficulty,
            metadata: ["won": won]
        )
        recordScore(gameScore)
    }
    
    func recordSnakeGame(score: Int, duration: TimeInterval?) {
        let gameScore = GameScore(
            gameType: .snake,
            score: score,
            playerName: UserManager.shared.currentUser?.username ?? "Player",
            duration: duration,
            metadata: ["final_score": score]
        )
        recordScore(gameScore)
    }
    
    func recordHangmanGame(won: Bool, remainingGuesses: Int, hintsUsed: Int, wordLength: Int) {
        let baseScore = won ? 100 : 0
        let bonusScore = won ? (remainingGuesses * 10) - (hintsUsed * 5) + (wordLength * 2) : 0
        let finalScore = max(0, baseScore + bonusScore)
        
        let gameScore = GameScore(
            gameType: .hangman,
            score: finalScore,
            playerName: UserManager.shared.currentUser?.username ?? "Player",
            metadata: [
                "won": won,
                "remaining_guesses": remainingGuesses,
                "hints_used": hintsUsed,
                "word_length": wordLength
            ]
        )
        recordScore(gameScore)
    }
    
    // MARK: - Score Retrieval
    func getHighScore(for gameType: GameType) -> Int {
        return scores[gameType]?.first?.score ?? 0
    }
    
    func getTopScores(for gameType: GameType, limit: Int = 10) -> [GameScore] {
        return Array(scores[gameType]?.prefix(limit) ?? [])
    }
    
    func getAllScores(for gameType: GameType) -> [GameScore] {
        return scores[gameType] ?? []
    }
    
    func getPlayerScores(for gameType: GameType, playerName: String) -> [GameScore] {
        return scores[gameType]?.filter { $0.playerName == playerName } ?? []
    }
    
    func getLeaderboard(for gameType: GameType, limit: Int = 10) -> [LeaderboardEntry] {
        let topScores = getTopScores(for: gameType, limit: limit)
        return topScores.enumerated().map { (index, score) in
            LeaderboardEntry(rank: index + 1, gameScore: score)
        }
    }
    
    func getGlobalLeaderboard(limit: Int = 20) -> [LeaderboardEntry] {
        var allScores: [GameScore] = []
        
        for gameType in GameType.allCases {
            allScores.append(contentsOf: scores[gameType] ?? [])
        }
        
        allScores.sort { $0.score > $1.score }
        
        return Array(allScores.prefix(limit)).enumerated().map { (index, score) in
            LeaderboardEntry(rank: index + 1, gameScore: score)
        }
    }
    
    // MARK: - Statistics
    func getGameStatistics(for gameType: GameType) -> GameStatistics {
        let gameScores = scores[gameType] ?? []
        
        return GameStatistics(
            gamesPlayed: gameScores.count,
            highScore: getHighScore(for: gameType),
            averageScore: gameScores.isEmpty ? 0 : gameScores.map { $0.score }.reduce(0, +) / gameScores.count,
            totalPlayTime: gameScores.compactMap { $0.duration }.reduce(0, +),
            winRate: calculateWinRate(for: gameType),
            aiGamesPlayed: gameScores.filter { $0.isAIGame }.count,
            lastPlayed: gameScores.first?.date
        )
    }
    
    func getOverallStatistics() -> OverallStatistics {
        var totalGames = 0
        var totalScore = 0
        var totalPlayTime: TimeInterval = 0
        var gameStats: [GameType: GameStatistics] = [:]
        
        for gameType in GameType.allCases {
            let stats = getGameStatistics(for: gameType)
            gameStats[gameType] = stats
            totalGames += stats.gamesPlayed
            totalScore += stats.highScore
            totalPlayTime += stats.totalPlayTime
        }
        
        return OverallStatistics(
            totalGamesPlayed: totalGames,
            totalScore: totalScore,
            totalPlayTime: totalPlayTime,
            favoriteGame: getFavoriteGame(),
            achievementsUnlocked: AchievementManager.shared.unlockedAchievements.count,
            gameStatistics: gameStats
        )
    }
    
    private func calculateWinRate(for gameType: GameType) -> Double {
        let gameScores = scores[gameType] ?? []
        
        switch gameType {
        case .ticTacToe, .connectFour:
            let wins = gameScores.filter { ($0.metadata["won"] as? Bool) == true }.count
            return gameScores.isEmpty ? 0 : Double(wins) / Double(gameScores.count)
        case .hangman:
            let wins = gameScores.filter { ($0.metadata["won"] as? Bool) == true }.count
            return gameScores.isEmpty ? 0 : Double(wins) / Double(gameScores.count)
        case .snake:
            // For Snake, we consider "winning" as scoring above average
            let averageScore = gameScores.isEmpty ? 0 : gameScores.map { $0.score }.reduce(0, +) / gameScores.count
            let aboveAverage = gameScores.filter { $0.score > averageScore }.count
            return gameScores.isEmpty ? 0 : Double(aboveAverage) / Double(gameScores.count)
        }
    }
    
    private func getFavoriteGame() -> GameType? {
        var gameCounts: [GameType: Int] = [:]
        
        for gameType in GameType.allCases {
            gameCounts[gameType] = scores[gameType]?.count ?? 0
        }
        
        return gameCounts.max(by: { $0.value < $1.value })?.key
    }
    
    // MARK: - Data Management
    func clearScores(for gameType: GameType? = nil) {
        if let gameType = gameType {
            scores[gameType] = []
        } else {
            scores.removeAll()
        }
        saveScores()
    }
    
    func exportScores() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return try encoder.encode(scores.mapValues { $0.map(ScoreData.init) })
        } catch {
            print("Failed to export scores: \(error)")
            return nil
        }
    }
    
    func importScores(from data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importedScores = try decoder.decode([String: [ScoreData]].self, from: data)
            
            for (gameTypeString, scoreDataArray) in importedScores {
                if let gameType = GameType(rawValue: gameTypeString) {
                    scores[gameType] = scoreDataArray.map(GameScore.init)
                }
            }
            
            saveScores()
            return true
        } catch {
            print("Failed to import scores: \(error)")
            return false
        }
    }
    
    // MARK: - Persistence
    private func saveScores() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(scores.mapValues { $0.map(ScoreData.init) })
            UserDefaults.standard.set(data, forKey: "SavedScores")
        } catch {
            print("Failed to save scores: \(error)")
        }
    }
    
    private func loadScores() {
        guard let data = UserDefaults.standard.data(forKey: "SavedScores") else { return }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loadedScores = try decoder.decode([String: [ScoreData]].self, from: data)
            
            for (gameTypeString, scoreDataArray) in loadedScores {
                if let gameType = GameType(rawValue: gameTypeString) {
                    scores[gameType] = scoreDataArray.map(GameScore.init)
                }
            }
        } catch {
            print("Failed to load scores: \(error)")
        }
    }
    
    // MARK: - Achievement Integration
    private func checkScoreAchievements(_ gameScore: GameScore) {
        AchievementManager.shared.recordGamePlayed(game: gameScore.gameType.rawValue)
        
        // Check for high score achievements
        if gameScore.score >= 100 {
            AchievementManager.shared.recordAchievement("high_score_100")
        }
        if gameScore.score >= 500 {
            AchievementManager.shared.recordAchievement("high_score_500")
        }
        
        // Check for game-specific achievements
        switch gameScore.gameType {
        case .snake:
            if gameScore.score >= 200 {
                AchievementManager.shared.recordAchievement("snake_master")
            }
        case .hangman:
            if let won = gameScore.metadata["won"] as? Bool, won,
               let hintsUsed = gameScore.metadata["hints_used"] as? Int, hintsUsed == 0 {
                AchievementManager.shared.recordAchievement("hangman_no_hints")
            }
        default:
            break
        }
    }
    
    // MARK: - Legacy Compatibility
    private func updateHighScoreManager(_ gameScore: GameScore) {
        let highScoreManager = HighScoreManager.shared
        
        switch gameScore.gameType {
        case .ticTacToe:
            if let won = gameScore.metadata["won"] as? Bool, won {
                highScoreManager.ticTacToeWins += 1
            }
        case .connectFour:
            if let won = gameScore.metadata["won"] as? Bool, won {
                highScoreManager.connectFourWins += 1
            }
        case .snake:
            if gameScore.score > highScoreManager.snakeHighScore {
                highScoreManager.snakeHighScore = gameScore.score
            }
            highScoreManager.snakeGamesPlayed += 1
        case .hangman:
            if let won = gameScore.metadata["won"] as? Bool, won {
                highScoreManager.hangmanTotalWins += 1
            }
        }
        
        highScoreManager.totalGamesPlayed += 1
    }
}

// MARK: - Supporting Data Structures
struct GameStatistics {
    let gamesPlayed: Int
    let highScore: Int
    let averageScore: Int
    let totalPlayTime: TimeInterval
    let winRate: Double
    let aiGamesPlayed: Int
    let lastPlayed: Date?
}

struct OverallStatistics {
    let totalGamesPlayed: Int
    let totalScore: Int
    let totalPlayTime: TimeInterval
    let favoriteGame: GameType?
    let achievementsUnlocked: Int
    let gameStatistics: [GameType: GameStatistics]
}

private struct ScoreData: Codable {
    let gameType: String
    let score: Int
    let playerName: String
    let isAIGame: Bool
    let difficulty: String?
    let date: Date
    let duration: TimeInterval?
    let metadata: [String: String] // Simplified metadata for JSON encoding
    
    init(from gameScore: GameScore) {
        self.gameType = gameScore.gameType.rawValue
        self.score = gameScore.score
        self.playerName = gameScore.playerName
        self.isAIGame = gameScore.isAIGame
        self.difficulty = gameScore.difficulty?.rawValue
        self.date = gameScore.date
        self.duration = gameScore.duration
        
        // Convert metadata to strings for JSON encoding
        self.metadata = gameScore.metadata.compactMapValues { "\($0)" }
    }
}

extension GameScore {
    init(from scoreData: ScoreData) {
        self.gameType = GameType(rawValue: scoreData.gameType) ?? .ticTacToe
        self.score = scoreData.score
        self.playerName = scoreData.playerName
        self.isAIGame = scoreData.isAIGame
        self.difficulty = scoreData.difficulty.flatMap(AIDifficulty.init)
        self.date = scoreData.date
        self.duration = scoreData.duration
        
        // Convert string metadata back to Any
        var convertedMetadata: [String: Any] = [:]
        for (key, value) in scoreData.metadata {
            if value == "true" || value == "false" {
                convertedMetadata[key] = Bool(value)
            } else if let intValue = Int(value) {
                convertedMetadata[key] = intValue
            } else if let doubleValue = Double(value) {
                convertedMetadata[key] = doubleValue
            } else {
                convertedMetadata[key] = value
            }
        }
        self.metadata = convertedMetadata
    }
}