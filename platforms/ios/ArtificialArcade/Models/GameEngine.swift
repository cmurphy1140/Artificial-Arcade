//
//  GameEngine.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation
import SpriteKit

protocol GameEngine {
    associatedtype GameState
    associatedtype Move
    
    var currentState: GameState { get set }
    var players: [Player] { get set }
    var isGameOver: Bool { get }
    var winner: Player? { get }
    
    init(players: [Player])
    
    func makeMove(_ move: Move, by player: Player) -> Bool
    func getValidMoves() -> [Move]
    func isValidMove(_ move: Move) -> Bool
    func checkGameEnd() -> GameResult?
    func resetGame()
    func getAIMove(for player: Player) -> Move?
}

// MARK: - Base Game Engine Implementation
class BaseGameEngine {
    var gameSession: GameSession = GameSession.shared
    var soundManager: SoundManager = SoundManager.shared
    var hapticManager: HapticManager = HapticManager.shared
    
    func playMoveSound() {
        soundManager.playEffect(.move)
    }
    
    func playWinSound() {
        soundManager.playEffect(.win)
        hapticManager.playHaptic(.success)
    }
    
    func playLossSound() {
        soundManager.playEffect(.lose)
        hapticManager.playHaptic(.error)
    }
    
    func playDrawSound() {
        soundManager.playEffect(.draw)
        hapticManager.playHaptic(.warning)
    }
    
    func playErrorSound() {
        soundManager.playEffect(.error)
        hapticManager.playHaptic(.error)
    }
}

// MARK: - Tic-Tac-Toe Engine
struct TicTacToeState {
    var board: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: 3)
    var currentPlayerIndex: Int = 0
    var moveCount: Int = 0
}

struct TicTacToeMove {
    let row: Int
    let col: Int
    let symbol: String
}

class TicTacToeEngine: BaseGameEngine, GameEngine {
    typealias GameState = TicTacToeState
    typealias Move = TicTacToeMove
    
    var currentState: TicTacToeState
    var players: [Player]
    
    var isGameOver: Bool {
        return checkGameEnd() != nil
    }
    
    var winner: Player? {
        guard let result = checkGameEnd() else { return nil }
        switch result {
        case .win:
            return players[currentState.currentPlayerIndex == 0 ? 1 : 0] // Previous player won
        default:
            return nil
        }
    }
    
    required init(players: [Player]) {
        self.currentState = TicTacToeState()
        self.players = players
        super.init()
    }
    
    func makeMove(_ move: TicTacToeMove, by player: Player) -> Bool {
        guard isValidMove(move) else { return false }
        
        currentState.board[move.row][move.col] = move.symbol
        currentState.moveCount += 1
        
        playMoveSound()
        
        // Record move in game session
        let moveData: [String: Any] = [
            "row": move.row,
            "col": move.col,
            "symbol": move.symbol
        ]
        let gameMove = GameMove(playerIndex: currentState.currentPlayerIndex, 
                              moveData: moveData, 
                              isAIMove: player.isAI)
        gameSession.addMoveToCurrentGame(gameMove)
        
        // Switch to next player
        currentState.currentPlayerIndex = (currentState.currentPlayerIndex + 1) % players.count
        
        return true
    }
    
    func getValidMoves() -> [TicTacToeMove] {
        var moves: [TicTacToeMove] = []
        let currentPlayer = players[currentState.currentPlayerIndex]
        
        for row in 0..<3 {
            for col in 0..<3 {
                if currentState.board[row][col].isEmpty {
                    moves.append(TicTacToeMove(row: row, col: col, symbol: currentPlayer.symbol ?? "X"))
                }
            }
        }
        
        return moves
    }
    
    func isValidMove(_ move: TicTacToeMove) -> Bool {
        return move.row >= 0 && move.row < 3 && 
               move.col >= 0 && move.col < 3 && 
               currentState.board[move.row][move.col].isEmpty
    }
    
    func checkGameEnd() -> GameResult? {
        // Check for win
        if checkWin() {
            return .win
        }
        
        // Check for draw
        if currentState.moveCount == 9 {
            return .draw
        }
        
        return nil
    }
    
    private func checkWin() -> Bool {
        let board = currentState.board
        
        // Check rows
        for row in 0..<3 {
            if !board[row][0].isEmpty && board[row][0] == board[row][1] && board[row][1] == board[row][2] {
                return true
            }
        }
        
        // Check columns
        for col in 0..<3 {
            if !board[0][col].isEmpty && board[0][col] == board[1][col] && board[1][col] == board[2][col] {
                return true
            }
        }
        
        // Check diagonals
        if !board[0][0].isEmpty && board[0][0] == board[1][1] && board[1][1] == board[2][2] {
            return true
        }
        if !board[0][2].isEmpty && board[0][2] == board[1][1] && board[1][1] == board[2][0] {
            return true
        }
        
        return false
    }
    
    func resetGame() {
        currentState = TicTacToeState()
    }
    
    func getAIMove(for player: Player) -> TicTacToeMove? {
        guard player.isAI, let difficulty = player.aiDifficulty else { return nil }
        
        // Use the existing AI implementation
        let ai = TicTacToeAI(difficulty: difficulty)
        return ai.getBestMove(for: currentState.board, playerSymbol: player.symbol ?? "O")
    }
}

// MARK: - Connect Four Engine
struct ConnectFourState {
    var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 7), count: 6)
    var currentPlayerIndex: Int = 0
    var moveCount: Int = 0
}

struct ConnectFourMove {
    let column: Int
    let player: Int
}

class ConnectFourEngine: BaseGameEngine, GameEngine {
    typealias GameState = ConnectFourState
    typealias Move = ConnectFourMove
    
    var currentState: ConnectFourState
    var players: [Player]
    
    var isGameOver: Bool {
        return checkGameEnd() != nil
    }
    
    var winner: Player? {
        guard let result = checkGameEnd() else { return nil }
        switch result {
        case .win:
            return players[currentState.currentPlayerIndex == 0 ? 1 : 0] // Previous player won
        default:
            return nil
        }
    }
    
    required init(players: [Player]) {
        self.currentState = ConnectFourState()
        self.players = players
        super.init()
    }
    
    func makeMove(_ move: ConnectFourMove, by player: Player) -> Bool {
        guard isValidMove(move) else { return false }
        
        // Find the lowest available row in the column
        guard let row = getLowestAvailableRow(column: move.column) else { return false }
        
        currentState.board[row][move.column] = move.player
        currentState.moveCount += 1
        
        playMoveSound()
        
        // Record move in game session
        let moveData: [String: Any] = [
            "row": row,
            "column": move.column,
            "player": move.player
        ]
        let gameMove = GameMove(playerIndex: currentState.currentPlayerIndex, 
                              moveData: moveData, 
                              isAIMove: player.isAI)
        gameSession.addMoveToCurrentGame(gameMove)
        
        // Switch to next player
        currentState.currentPlayerIndex = (currentState.currentPlayerIndex + 1) % players.count
        
        return true
    }
    
    private func getLowestAvailableRow(column: Int) -> Int? {
        for row in (0..<6).reversed() {
            if currentState.board[row][column] == 0 {
                return row
            }
        }
        return nil
    }
    
    func getValidMoves() -> [ConnectFourMove] {
        var moves: [ConnectFourMove] = []
        let playerNumber = currentState.currentPlayerIndex + 1
        
        for col in 0..<7 {
            if currentState.board[0][col] == 0 {
                moves.append(ConnectFourMove(column: col, player: playerNumber))
            }
        }
        
        return moves
    }
    
    func isValidMove(_ move: ConnectFourMove) -> Bool {
        return move.column >= 0 && move.column < 7 && currentState.board[0][move.column] == 0
    }
    
    func checkGameEnd() -> GameResult? {
        // Check for win
        if checkWin() {
            return .win
        }
        
        // Check for draw (board full)
        if currentState.board[0].allSatisfy({ $0 != 0 }) {
            return .draw
        }
        
        return nil
    }
    
    private func checkWin() -> Bool {
        let board = currentState.board
        
        // Check all positions for 4 in a row
        for row in 0..<6 {
            for col in 0..<7 {
                let player = board[row][col]
                if player != 0 {
                    // Check horizontal
                    if col <= 3 {
                        if board[row][col + 1] == player &&
                           board[row][col + 2] == player &&
                           board[row][col + 3] == player {
                            return true
                        }
                    }
                    
                    // Check vertical
                    if row <= 2 {
                        if board[row + 1][col] == player &&
                           board[row + 2][col] == player &&
                           board[row + 3][col] == player {
                            return true
                        }
                    }
                    
                    // Check diagonal (down-right)
                    if row <= 2 && col <= 3 {
                        if board[row + 1][col + 1] == player &&
                           board[row + 2][col + 2] == player &&
                           board[row + 3][col + 3] == player {
                            return true
                        }
                    }
                    
                    // Check diagonal (down-left)
                    if row <= 2 && col >= 3 {
                        if board[row + 1][col - 1] == player &&
                           board[row + 2][col - 2] == player &&
                           board[row + 3][col - 3] == player {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func resetGame() {
        currentState = ConnectFourState()
    }
    
    func getAIMove(for player: Player) -> ConnectFourMove? {
        guard player.isAI, let difficulty = player.aiDifficulty else { return nil }
        
        // Use the existing AI implementation
        let ai = ConnectFourAI(difficulty: difficulty)
        let column = ai.getBestMove(for: currentState.board)
        let playerNumber = currentState.currentPlayerIndex + 1
        
        return ConnectFourMove(column: column, player: playerNumber)
    }
}

// MARK: - Game Engine Factory
class GameEngineFactory {
    static func createEngine(for gameType: GameType, players: [Player]) -> Any {
        switch gameType {
        case .ticTacToe:
            return TicTacToeEngine(players: players)
        case .connectFour:
            return ConnectFourEngine(players: players)
        case .snake:
            // Snake doesn't use the traditional engine pattern since it's more event-driven
            return SnakeGameLogic()
        case .hangman:
            // Hangman also uses a different pattern
            return HangmanGameLogic()
        }
    }
}

// MARK: - Simplified Logic Classes for Snake and Hangman
class SnakeGameLogic: BaseGameEngine {
    // Snake game logic is already well implemented in SnakeScene
    // This is a placeholder for consistency
}

class HangmanGameLogic: BaseGameEngine {
    // Hangman game logic is already well implemented in HangmanScene
    // This is a placeholder for consistency
}