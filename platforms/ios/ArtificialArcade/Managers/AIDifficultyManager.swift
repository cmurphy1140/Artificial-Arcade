//
//  AIDifficultyManager.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/10/25.
//

import Foundation

enum AIDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium" 
    case hard = "Hard"
    case expert = "Expert"
    
    var displayName: String {
        switch self {
        case .easy: return "🟢 Easy - Learning Mode"
        case .medium: return "🟡 Medium - Casual Play"
        case .hard: return "🟠 Hard - Challenging"
        case .expert: return "🔴 Expert - Master Level"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "AI makes occasional mistakes, perfect for beginners"
        case .medium: return "Balanced AI with good strategy and some errors"
        case .hard: return "Strong AI that rarely makes mistakes"
        case .expert: return "Perfect AI that never makes suboptimal moves"
        }
    }
    
    var ticTacToeDepth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 3
        case .hard: return 6
        case .expert: return 9
        }
    }
    
    var connectFourDepth: Int {
        switch self {
        case .easy: return 2
        case .medium: return 4
        case .hard: return 6
        case .expert: return 8
        }
    }
    
    var hangmanHintFrequency: Double {
        switch self {
        case .easy: return 0.8 // 80% chance of good hints
        case .medium: return 0.6
        case .hard: return 0.4
        case .expert: return 0.2 // Only 20% chance of helpful hints
        }
    }
    
    var errorProbability: Double {
        switch self {
        case .easy: return 0.25 // 25% chance of AI making a mistake
        case .medium: return 0.15
        case .hard: return 0.05
        case .expert: return 0.0 // Perfect play
        }
    }
}

class AIDifficultyManager {
    static let shared = AIDifficultyManager()
    
    private init() {}
    
    // Keys for UserDefaults
    private enum Keys {
        static let ticTacToeDifficulty = "TicTacToeDifficulty"
        static let connectFourDifficulty = "ConnectFourDifficulty"
        static let hangmanDifficulty = "HangmanDifficulty"
        static let generalDifficulty = "GeneralAIDifficulty"
    }
    
    var ticTacToeDifficulty: AIDifficulty {
        get {
            let rawValue = UserDefaults.standard.string(forKey: Keys.ticTacToeDifficulty) ?? AIDifficulty.medium.rawValue
            return AIDifficulty(rawValue: rawValue) ?? .medium
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.ticTacToeDifficulty)
        }
    }
    
    var connectFourDifficulty: AIDifficulty {
        get {
            let rawValue = UserDefaults.standard.string(forKey: Keys.connectFourDifficulty) ?? AIDifficulty.medium.rawValue
            return AIDifficulty(rawValue: rawValue) ?? .medium
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.connectFourDifficulty)
        }
    }
    
    var hangmanDifficulty: AIDifficulty {
        get {
            let rawValue = UserDefaults.standard.string(forKey: Keys.hangmanDifficulty) ?? AIDifficulty.medium.rawValue
            return AIDifficulty(rawValue: rawValue) ?? .medium
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.hangmanDifficulty)
        }
    }
    
    var generalDifficulty: AIDifficulty {
        get {
            let rawValue = UserDefaults.standard.string(forKey: Keys.generalDifficulty) ?? AIDifficulty.medium.rawValue
            return AIDifficulty(rawValue: rawValue) ?? .medium
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.generalDifficulty)
            // Update all individual game difficulties
            ticTacToeDifficulty = newValue
            connectFourDifficulty = newValue
            hangmanDifficulty = newValue
        }
    }
    
    func shouldMakeError(for difficulty: AIDifficulty) -> Bool {
        return Double.random(in: 0...1) < difficulty.errorProbability
    }
    
    func getRandomizedMove<T>(bestMove: T, alternatives: [T], difficulty: AIDifficulty) -> T {
        if shouldMakeError(for: difficulty) && !alternatives.isEmpty {
            return alternatives.randomElement() ?? bestMove
        }
        return bestMove
    }
}