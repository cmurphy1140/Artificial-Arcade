//
//  GameState.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation

enum GameType: String, CaseIterable {
    case ticTacToe = "tic_tac_toe"
    case connectFour = "connect_four"
    case snake = "snake"
    case hangman = "hangman"
    
    var displayName: String {
        switch self {
        case .ticTacToe: return "Tic-Tac-Toe"
        case .connectFour: return "Connect Four"
        case .snake: return "Snake"
        case .hangman: return "Hangman"
        }
    }
}

enum GameStatus {
    case notStarted
    case inProgress
    case paused
    case completed
    case aborted
}

enum GameResult {
    case win
    case loss
    case draw
    case aborted
}

struct GameState {
    let gameType: GameType
    var status: GameStatus
    var result: GameResult?
    var score: Int
    var startTime: Date?
    var endTime: Date?
    var moves: [GameMove]
    var playerCount: Int
    var aiDifficulty: AIDifficulty?
    var metadata: [String: Any]
    
    init(gameType: GameType, playerCount: Int = 1, aiDifficulty: AIDifficulty? = nil) {
        self.gameType = gameType
        self.status = .notStarted
        self.score = 0
        self.moves = []
        self.playerCount = playerCount
        self.aiDifficulty = aiDifficulty
        self.metadata = [:]
    }
    
    mutating func start() {
        status = .inProgress
        startTime = Date()
    }
    
    mutating func end(with result: GameResult) {
        status = .completed
        endTime = Date()
        self.result = result
    }
    
    mutating func pause() {
        if status == .inProgress {
            status = .paused
        }
    }
    
    mutating func resume() {
        if status == .paused {
            status = .inProgress
        }
    }
    
    mutating func addMove(_ move: GameMove) {
        moves.append(move)
    }
    
    var duration: TimeInterval? {
        guard let startTime = startTime else { return nil }
        let endTime = self.endTime ?? Date()
        return endTime.timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        return status == .inProgress || status == .paused
    }
}

struct GameMove {
    let timestamp: Date
    let playerIndex: Int
    let moveData: [String: Any]
    let isAIMove: Bool
    
    init(playerIndex: Int, moveData: [String: Any], isAIMove: Bool = false) {
        self.timestamp = Date()
        self.playerIndex = playerIndex
        self.moveData = moveData
        self.isAIMove = isAIMove
    }
}

// MARK: - Game Session Management
class GameSession {
    static let shared = GameSession()
    
    private var currentGame: GameState?
    private var gameHistory: [GameState] = []
    
    private init() {}
    
    func startGame(type: GameType, playerCount: Int = 1, aiDifficulty: AIDifficulty? = nil) -> GameState {
        // End current game if active
        if let current = currentGame, current.isActive {
            endCurrentGame(with: .aborted)
        }
        
        var newGame = GameState(gameType: type, playerCount: playerCount, aiDifficulty: aiDifficulty)
        newGame.start()
        currentGame = newGame
        
        return newGame
    }
    
    func getCurrentGame() -> GameState? {
        return currentGame
    }
    
    func updateCurrentGame(_ game: GameState) {
        currentGame = game
    }
    
    func endCurrentGame(with result: GameResult) {
        guard var current = currentGame else { return }
        current.end(with: result)
        gameHistory.append(current)
        currentGame = nil
        
        // Record statistics
        recordGameStatistics(current)
    }
    
    func pauseCurrentGame() {
        currentGame?.pause()
    }
    
    func resumeCurrentGame() {
        currentGame?.resume()
    }
    
    func addMoveToCurrentGame(_ move: GameMove) {
        currentGame?.addMove(move)
    }
    
    private func recordGameStatistics(_ game: GameState) {
        // Update high scores and achievement progress
        HighScoreManager.shared.recordGameResult(game)
        AchievementManager.shared.recordGamePlayed(game: game.gameType.rawValue)
        
        // Add experience points
        if let result = game.result {
            let experiencePoints: Int
            switch result {
            case .win: experiencePoints = 50
            case .draw: experiencePoints = 25
            case .loss: experiencePoints = 10
            case .aborted: experiencePoints = 5
            }
            UserManager.shared.addExperience(experiencePoints)
        }
        
        // Update play time
        if let duration = game.duration {
            UserManager.shared.addPlayTime(duration)
        }
    }
    
    func getGameHistory(for gameType: GameType? = nil) -> [GameState] {
        if let gameType = gameType {
            return gameHistory.filter { $0.gameType == gameType }
        }
        return gameHistory
    }
    
    func clearHistory() {
        gameHistory.removeAll()
    }
}

// MARK: - Extensions
extension HighScoreManager {
    func recordGameResult(_ game: GameState) {
        guard let result = game.result else { return }
        
        switch game.gameType {
        case .ticTacToe:
            if result == .win {
                if game.aiDifficulty != nil {
                    ticTacToeWins += 1
                }
            }
        case .connectFour:
            if result == .win {
                if game.aiDifficulty != nil {
                    connectFourWins += 1
                }
            }
        case .snake:
            if game.score > snakeHighScore {
                snakeHighScore = game.score
            }
            snakeGamesPlayed += 1
        case .hangman:
            if result == .win {
                hangmanTotalWins += 1
                hangmanCurrentStreak += 1
                if hangmanCurrentStreak > hangmanBestStreak {
                    hangmanBestStreak = hangmanCurrentStreak
                }
            } else {
                hangmanCurrentStreak = 0
            }
        }
        
        totalGamesPlayed += 1
        if let duration = game.duration {
            totalTimeSpent += Int(duration)
        }
    }
}