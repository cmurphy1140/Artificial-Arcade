//
//  HighScoreManager.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation

class HighScoreManager {
    static let shared = HighScoreManager()
    
    private init() {}
    
    // Keys for different games and modes
    private enum Keys {
        static let ticTacToeWins = "TicTacToeWins"
        static let ticTacToeAIWins = "TicTacToeAIWins"
        static let hangmanBestStreak = "HangmanBestStreak"
        static let hangmanCurrentStreak = "HangmanCurrentStreak"
        static let hangmanTotalWins = "HangmanTotalWins"
        static let snakeHighScore = "SnakeHighScore"
        static let snakeGamesPlayed = "SnakeGamesPlayed"
        static let connectFourWins = "ConnectFourWins"
        static let connectFourAIWins = "ConnectFourAIWins"
        static let totalGamesPlayed = "TotalGamesPlayed"
        static let totalTimeSpent = "TotalTimeSpent"
    }
    
    // MARK: - Tic-Tac-Toe Stats
    var ticTacToeWins: Int {
        get { UserDefaults.standard.integer(forKey: Keys.ticTacToeWins) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.ticTacToeWins) }
    }
    
    var ticTacToeAIWins: Int {
        get { UserDefaults.standard.integer(forKey: Keys.ticTacToeAIWins) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.ticTacToeAIWins) }
    }
    
    // MARK: - Hangman Stats
    var hangmanBestStreak: Int {
        get { UserDefaults.standard.integer(forKey: Keys.hangmanBestStreak) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hangmanBestStreak) }
    }
    
    var hangmanCurrentStreak: Int {
        get { UserDefaults.standard.integer(forKey: Keys.hangmanCurrentStreak) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hangmanCurrentStreak) }
    }
    
    var hangmanTotalWins: Int {
        get { UserDefaults.standard.integer(forKey: Keys.hangmanTotalWins) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hangmanTotalWins) }
    }
    
    // MARK: - Snake Stats
    var snakeHighScore: Int {
        get { UserDefaults.standard.integer(forKey: Keys.snakeHighScore) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.snakeHighScore) }
    }
    
    var snakeGamesPlayed: Int {
        get { UserDefaults.standard.integer(forKey: Keys.snakeGamesPlayed) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.snakeGamesPlayed) }
    }
    
    // MARK: - Connect Four Stats
    var connectFourWins: Int {
        get { UserDefaults.standard.integer(forKey: Keys.connectFourWins) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.connectFourWins) }
    }
    
    var connectFourAIWins: Int {
        get { UserDefaults.standard.integer(forKey: Keys.connectFourAIWins) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.connectFourAIWins) }
    }
    
    // MARK: - Overall Stats
    var totalGamesPlayed: Int {
        get { UserDefaults.standard.integer(forKey: Keys.totalGamesPlayed) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.totalGamesPlayed) }
    }
    
    var totalTimeSpent: TimeInterval {
        get { UserDefaults.standard.double(forKey: Keys.totalTimeSpent) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.totalTimeSpent) }
    }
    
    // MARK: - Game Result Recording
    func recordTicTacToeResult(playerWon: Bool, vsAI: Bool) {
        totalGamesPlayed += 1
        if vsAI {
            if playerWon {
                ticTacToeWins += 1
            } else {
                ticTacToeAIWins += 1
            }
        }
    }
    
    func recordHangmanResult(won: Bool) {
        totalGamesPlayed += 1
        if won {
            hangmanTotalWins += 1
            hangmanCurrentStreak += 1
            if hangmanCurrentStreak > hangmanBestStreak {
                hangmanBestStreak = hangmanCurrentStreak
            }
        } else {
            hangmanCurrentStreak = 0
        }
    }
    
    func recordSnakeScore(_ score: Int) {
        totalGamesPlayed += 1
        snakeGamesPlayed += 1
        if score > snakeHighScore {
            snakeHighScore = score
        }
    }
    
    func recordConnectFourResult(playerWon: Bool, vsAI: Bool) {
        totalGamesPlayed += 1
        if vsAI {
            if playerWon {
                connectFourWins += 1
            } else {
                connectFourAIWins += 1
            }
        }
    }
    
    // MARK: - Stats Summary
    func getGameSummary() -> [String: Any] {
        return [
            "totalGames": totalGamesPlayed,
            "ticTacToeWins": ticTacToeWins,
            "ticTacToeAIWins": ticTacToeAIWins,
            "hangmanStreak": hangmanBestStreak,
            "hangmanWins": hangmanTotalWins,
            "snakeHigh": snakeHighScore,
            "snakeGames": snakeGamesPlayed,
            "connectWins": connectFourWins,
            "connectAIWins": connectFourAIWins
        ]
    }
}