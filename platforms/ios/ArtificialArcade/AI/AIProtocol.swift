//
//  AIProtocol.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation

protocol AIProtocol {
    associatedtype GameState
    associatedtype Move
    
    var difficulty: AIDifficulty { get }
    
    func getBestMove(for gameState: GameState) -> Move
    func evaluatePosition(_ gameState: GameState) -> Int
    func shouldMakeError() -> Bool
}

// MARK: - Base AI Implementation
class BaseAI {
    let difficulty: AIDifficulty
    
    init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
    }
    
    func shouldMakeError() -> Bool {
        return Double.random(in: 0...1) < difficulty.errorProbability
    }
    
    func addDelay(completion: @escaping () -> Void) {
        let delay: TimeInterval
        switch difficulty {
        case .easy: delay = Double.random(in: 0.5...1.5)
        case .medium: delay = Double.random(in: 0.3...1.0) 
        case .hard: delay = Double.random(in: 0.1...0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion()
        }
    }
}

// MARK: - AI Strategy Protocols
protocol MinimaxAI: AIProtocol {
    func minimax(gameState: GameState, depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> (score: Int, move: Move?)
    func getGameDepth() -> Int
}

protocol HeuristicAI: AIProtocol {
    func evaluateHeuristics(_ gameState: GameState) -> Int
    func getPossibleMoves(_ gameState: GameState) -> [Move]
}

// MARK: - AI Difficulty Extensions
extension AIDifficulty {
    var searchDepth: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 7
        }
    }
    
    var thinkingTime: TimeInterval {
        switch self {
        case .easy: return 1.0
        case .medium: return 0.7
        case .hard: return 0.3
        }
    }
    
    var moveVariation: Int {
        switch self {
        case .easy: return 3  // Consider top 3 moves
        case .medium: return 2  // Consider top 2 moves
        case .hard: return 1  // Only best move
        }
    }
}

// MARK: - AI Move Selection Utilities
struct AIMoveSelector {
    static func selectMove<T>(from moves: [T], difficulty: AIDifficulty, scoreEvaluator: (T) -> Int) -> T? {
        guard !moves.isEmpty else { return nil }
        
        // Sort moves by score
        let scoredMoves = moves.map { (move: $0, score: scoreEvaluator($0)) }
        let sortedMoves = scoredMoves.sorted { $0.score > $1.score }
        
        // Apply difficulty-based selection
        let considerCount = min(difficulty.moveVariation, sortedMoves.count)
        let topMoves = Array(sortedMoves.prefix(considerCount))
        
        // Add randomness for lower difficulties
        if difficulty != .hard && Double.random(in: 0...1) < difficulty.errorProbability {
            // Sometimes pick a random move from the top moves
            return topMoves.randomElement()?.move
        }
        
        // Return best move
        return topMoves.first?.move
    }
    
    static func addRandomVariation<T>(to bestMove: T, alternatives: [T], difficulty: AIDifficulty) -> T {
        guard !alternatives.isEmpty && Double.random(in: 0...1) < difficulty.errorProbability else {
            return bestMove
        }
        
        // Return a random alternative move based on difficulty
        return alternatives.randomElement() ?? bestMove
    }
}

// MARK: - AI Performance Tracker
class AIPerformanceTracker {
    static let shared = AIPerformanceTracker()
    
    private var gameStats: [String: [AIDifficulty: AIStats]] = [:]
    
    private init() {}
    
    func recordGame(gameType: String, difficulty: AIDifficulty, won: Bool, moveCount: Int, thinkingTime: TimeInterval) {
        if gameStats[gameType] == nil {
            gameStats[gameType] = [:]
        }
        
        if gameStats[gameType]![difficulty] == nil {
            gameStats[gameType]![difficulty] = AIStats()
        }
        
        gameStats[gameType]![difficulty]!.recordGame(won: won, moveCount: moveCount, thinkingTime: thinkingTime)
    }
    
    func getStats(for gameType: String, difficulty: AIDifficulty) -> AIStats? {
        return gameStats[gameType]?[difficulty]
    }
    
    func getAllStats() -> [String: [AIDifficulty: AIStats]] {
        return gameStats
    }
}

struct AIStats {
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var totalMoves: Int = 0
    var totalThinkingTime: TimeInterval = 0
    
    var winRate: Double {
        return gamesPlayed > 0 ? Double(gamesWon) / Double(gamesPlayed) : 0
    }
    
    var averageMovesPerGame: Double {
        return gamesPlayed > 0 ? Double(totalMoves) / Double(gamesPlayed) : 0
    }
    
    var averageThinkingTime: TimeInterval {
        return gamesPlayed > 0 ? totalThinkingTime / Double(gamesPlayed) : 0
    }
    
    mutating func recordGame(won: Bool, moveCount: Int, thinkingTime: TimeInterval) {
        gamesPlayed += 1
        if won { gamesWon += 1 }
        totalMoves += moveCount
        totalThinkingTime += thinkingTime
    }
}