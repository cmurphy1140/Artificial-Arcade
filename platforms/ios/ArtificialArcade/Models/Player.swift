//
//  Player.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation

enum PlayerType {
    case human
    case ai
}

enum AIDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Perfect for beginners"
        case .medium: return "Balanced challenge"
        case .hard: return "Expert level AI"
        }
    }
    
    // Game-specific difficulty settings
    var ticTacToeDepth: Int {
        switch self {
        case .easy: return 3
        case .medium: return 6
        case .hard: return 9
        }
    }
    
    var connectFourDepth: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 7
        }
    }
    
    var errorProbability: Double {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.1
        case .hard: return 0.0
        }
    }
}

struct Player {
    let id: UUID
    let name: String
    let type: PlayerType
    let aiDifficulty: AIDifficulty?
    var symbol: String?
    var color: String?
    var score: Int
    var wins: Int
    var losses: Int
    var draws: Int
    
    init(name: String, type: PlayerType, aiDifficulty: AIDifficulty? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.aiDifficulty = type == .ai ? (aiDifficulty ?? .medium) : nil
        self.score = 0
        self.wins = 0
        self.losses = 0
        self.draws = 0
    }
    
    var isAI: Bool {
        return type == .ai
    }
    
    var isHuman: Bool {
        return type == .human
    }
    
    var winRate: Double {
        let totalGames = wins + losses + draws
        return totalGames > 0 ? Double(wins) / Double(totalGames) : 0.0
    }
    
    mutating func recordWin() {
        wins += 1
    }
    
    mutating func recordLoss() {
        losses += 1
    }
    
    mutating func recordDraw() {
        draws += 1
    }
    
    mutating func addScore(_ points: Int) {
        score += points
    }
    
    mutating func resetScore() {
        score = 0
    }
}

// MARK: - Game-specific Player Extensions

extension Player {
    static func createHumanPlayer(name: String) -> Player {
        return Player(name: name, type: .human)
    }
    
    static func createAIPlayer(difficulty: AIDifficulty = .medium) -> Player {
        let aiName: String
        switch difficulty {
        case .easy:
            aiName = "🤖 Rookie AI"
        case .medium:
            aiName = "🤖 Smart AI"
        case .hard:
            aiName = "🤖 Master AI"
        }
        
        return Player(name: aiName, type: .ai, aiDifficulty: difficulty)
    }
    
    // Tic-Tac-Toe specific
    static func createTicTacToePlayer(isAI: Bool, symbol: String, difficulty: AIDifficulty? = nil) -> Player {
        var player: Player
        if isAI {
            player = createAIPlayer(difficulty: difficulty ?? .medium)
        } else {
            player = createHumanPlayer(name: "Player")
        }
        player.symbol = symbol
        return player
    }
    
    // Connect Four specific
    static func createConnectFourPlayer(isAI: Bool, playerNumber: Int, difficulty: AIDifficulty? = nil) -> Player {
        var player: Player
        if isAI {
            player = createAIPlayer(difficulty: difficulty ?? .medium)
        } else {
            player = createHumanPlayer(name: "Player \(playerNumber)")
        }
        player.color = playerNumber == 1 ? "red" : "yellow"
        return player
    }
    
    // Snake specific  
    static func createSnakePlayer(name: String) -> Player {
        return createHumanPlayer(name: name)
    }
    
    // Hangman specific
    static func createHangmanPlayer() -> Player {
        return createHumanPlayer(name: "Player")
    }
}

// MARK: - Player Manager
class PlayerManager {
    static let shared = PlayerManager()
    
    private var players: [UUID: Player] = [:]
    private var currentGamePlayers: [Player] = []
    
    private init() {}
    
    func addPlayer(_ player: Player) {
        players[player.id] = player
    }
    
    func removePlayer(_ playerId: UUID) {
        players.removeValue(forKey: playerId)
    }
    
    func getPlayer(_ playerId: UUID) -> Player? {
        return players[playerId]
    }
    
    func updatePlayer(_ player: Player) {
        players[player.id] = player
    }
    
    func setCurrentGamePlayers(_ players: [Player]) {
        currentGamePlayers = players
        // Add to players dictionary
        for player in players {
            self.players[player.id] = player
        }
    }
    
    func getCurrentGamePlayers() -> [Player] {
        return currentGamePlayers
    }
    
    func clearCurrentGame() {
        currentGamePlayers.removeAll()
    }
    
    func recordGameResult(playerId: UUID, result: GameResult) {
        guard var player = players[playerId] else { return }
        
        switch result {
        case .win:
            player.recordWin()
        case .loss:
            player.recordLoss()
        case .draw:
            player.recordDraw()
        case .aborted:
            break // Don't record aborted games
        }
        
        players[playerId] = player
        
        // Update current game players array if needed
        if let index = currentGamePlayers.firstIndex(where: { $0.id == playerId }) {
            currentGamePlayers[index] = player
        }
    }
    
    func addScoreToPlayer(_ playerId: UUID, points: Int) {
        guard var player = players[playerId] else { return }
        player.addScore(points)
        players[playerId] = player
        
        // Update current game players array if needed
        if let index = currentGamePlayers.firstIndex(where: { $0.id == playerId }) {
            currentGamePlayers[index] = player
        }
    }
    
    func resetPlayerScores() {
        for playerId in players.keys {
            players[playerId]?.resetScore()
        }
        
        for index in currentGamePlayers.indices {
            currentGamePlayers[index].resetScore()
        }
    }
    
    func getAllPlayers() -> [Player] {
        return Array(players.values)
    }
    
    func getHumanPlayers() -> [Player] {
        return players.values.filter { $0.isHuman }
    }
    
    func getAIPlayers() -> [Player] {
        return players.values.filter { $0.isAI }
    }
}