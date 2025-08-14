//
//  ConnectFourAI.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation

class ConnectFourAI: BaseAI, MinimaxAI {
    typealias GameState = [[Int]]
    typealias Move = Int // Column number
    
    private let aiPlayer: Int
    private let humanPlayer: Int
    private let rows = 6
    private let cols = 7
    
    init(difficulty: AIDifficulty, aiPlayer: Int = 2, humanPlayer: Int = 1) {
        self.aiPlayer = aiPlayer
        self.humanPlayer = humanPlayer
        super.init(difficulty: difficulty)
    }
    
    func getBestMove(for gameState: [[Int]]) -> Int {
        let depth = getGameDepth()
        let (_, bestColumn) = minimax(gameState: gameState, depth: depth, isMaximizing: true, alpha: Int.min, beta: Int.max)
        
        // Apply difficulty-based errors
        if let column = bestColumn, shouldMakeError() {
            let alternatives = getPossibleMoves(gameState).filter { $0 != column }
            if !alternatives.isEmpty {
                return AIMoveSelector.addRandomVariation(to: column, alternatives: alternatives, difficulty: difficulty)
            }
        }
        
        return bestColumn ?? getRandomMove(for: gameState)
    }
    
    func minimax(gameState: [[Int]], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> (score: Int, move: Int?) {
        // Check terminal states
        if let winner = getWinner(gameState) {
            if winner == aiPlayer {
                return (1000 + depth, nil) // Prefer faster wins
            } else if winner == humanPlayer {
                return (-1000 - depth, nil) // Prefer slower losses
            }
        }
        
        if isBoardFull(gameState) {
            return (0, nil) // Draw
        }
        
        if depth == 0 {
            return (evaluatePosition(gameState), nil)
        }
        
        var alpha = alpha
        var beta = beta
        var bestMove: Int?
        
        if isMaximizing {
            var maxScore = Int.min
            
            for column in getPossibleMoves(gameState) {
                let newState = makeMove(gameState, column: column, player: aiPlayer)
                let (score, _) = minimax(gameState: newState, depth: depth - 1, isMaximizing: false, alpha: alpha, beta: beta)
                
                if score > maxScore {
                    maxScore = score
                    bestMove = column
                }
                
                alpha = max(alpha, score)
                if beta <= alpha {
                    break // Beta cutoff
                }
            }
            
            return (maxScore, bestMove)
        } else {
            var minScore = Int.max
            
            for column in getPossibleMoves(gameState) {
                let newState = makeMove(gameState, column: column, player: humanPlayer)
                let (score, _) = minimax(gameState: newState, depth: depth - 1, isMaximizing: true, alpha: alpha, beta: beta)
                
                if score < minScore {
                    minScore = score
                    bestMove = column
                }
                
                beta = min(beta, score)
                if beta <= alpha {
                    break // Alpha cutoff
                }
            }
            
            return (minScore, bestMove)
        }
    }
    
    func evaluatePosition(_ gameState: [[Int]]) -> Int {
        var score = 0
        
        // Evaluate all possible 4-in-a-row positions
        for row in 0..<rows {
            for col in 0..<cols {
                // Horizontal
                if col <= cols - 4 {
                    score += evaluateWindow([gameState[row][col], gameState[row][col + 1], gameState[row][col + 2], gameState[row][col + 3]])
                }
                
                // Vertical
                if row <= rows - 4 {
                    score += evaluateWindow([gameState[row][col], gameState[row + 1][col], gameState[row + 2][col], gameState[row + 3][col]])
                }
                
                // Diagonal (top-left to bottom-right)
                if row <= rows - 4 && col <= cols - 4 {
                    score += evaluateWindow([gameState[row][col], gameState[row + 1][col + 1], gameState[row + 2][col + 2], gameState[row + 3][col + 3]])
                }
                
                // Diagonal (top-right to bottom-left)
                if row <= rows - 4 && col >= 3 {
                    score += evaluateWindow([gameState[row][col], gameState[row + 1][col - 1], gameState[row + 2][col - 2], gameState[row + 3][col - 3]])
                }
            }
        }
        
        // Center column preference
        for row in 0..<rows {
            if gameState[row][cols / 2] == aiPlayer {
                score += 3
            } else if gameState[row][cols / 2] == humanPlayer {
                score -= 3
            }
        }
        
        return score
    }
    
    private func evaluateWindow(_ window: [Int]) -> Int {
        let aiCount = window.filter { $0 == aiPlayer }.count
        let humanCount = window.filter { $0 == humanPlayer }.count
        let emptyCount = window.filter { $0 == 0 }.count
        
        if aiCount == 4 { return 100 }
        if humanCount == 4 { return -100 }
        
        if aiCount == 3 && emptyCount == 1 { return 10 }
        if humanCount == 3 && emptyCount == 1 { return -10 }
        
        if aiCount == 2 && emptyCount == 2 { return 2 }
        if humanCount == 2 && emptyCount == 2 { return -2 }
        
        if aiCount == 1 && emptyCount == 3 { return 1 }
        if humanCount == 1 && emptyCount == 3 { return -1 }
        
        return 0
    }
    
    func getGameDepth() -> Int {
        return difficulty.connectFourDepth
    }
    
    private func getPossibleMoves(_ gameState: [[Int]]) -> [Int] {
        var moves: [Int] = []
        
        for col in 0..<cols {
            if gameState[0][col] == 0 {
                moves.append(col)
            }
        }
        
        return moves
    }
    
    private func getRandomMove(for gameState: [[Int]]) -> Int {
        let possibleMoves = getPossibleMoves(gameState)
        return possibleMoves.randomElement() ?? cols / 2
    }
    
    private func makeMove(_ gameState: [[Int]], column: Int, player: Int) -> [[Int]] {
        var newState = gameState
        
        for row in (0..<rows).reversed() {
            if newState[row][column] == 0 {
                newState[row][column] = player
                break
            }
        }
        
        return newState
    }
    
    private func getWinner(_ gameState: [[Int]]) -> Int? {
        // Check all positions for 4 in a row
        for row in 0..<rows {
            for col in 0..<cols {
                let player = gameState[row][col]
                if player != 0 {
                    // Check horizontal
                    if col <= cols - 4 &&
                       gameState[row][col + 1] == player &&
                       gameState[row][col + 2] == player &&
                       gameState[row][col + 3] == player {
                        return player
                    }
                    
                    // Check vertical
                    if row <= rows - 4 &&
                       gameState[row + 1][col] == player &&
                       gameState[row + 2][col] == player &&
                       gameState[row + 3][col] == player {
                        return player
                    }
                    
                    // Check diagonal (down-right)
                    if row <= rows - 4 && col <= cols - 4 &&
                       gameState[row + 1][col + 1] == player &&
                       gameState[row + 2][col + 2] == player &&
                       gameState[row + 3][col + 3] == player {
                        return player
                    }
                    
                    // Check diagonal (down-left)
                    if row <= rows - 4 && col >= 3 &&
                       gameState[row + 1][col - 1] == player &&
                       gameState[row + 2][col - 2] == player &&
                       gameState[row + 3][col - 3] == player {
                        return player
                    }
                }
            }
        }
        
        return nil
    }
    
    private func isBoardFull(_ gameState: [[Int]]) -> Bool {
        return gameState[0].allSatisfy { $0 != 0 }
    }
}

// MARK: - Strategic Move Patterns
extension ConnectFourAI {
    private func getStrategicMove(_ gameState: [[Int]]) -> Int? {
        // 1. Try to win immediately
        if let winMove = findWinningMove(gameState, for: aiPlayer) {
            return winMove
        }
        
        // 2. Block opponent from winning
        if let blockMove = findWinningMove(gameState, for: humanPlayer) {
            return blockMove
        }
        
        // 3. Look for setup moves (create multiple threats)
        if let setupMove = findSetupMove(gameState) {
            return setupMove
        }
        
        // 4. Control center columns
        let centerColumns = [3, 2, 4, 1, 5, 0, 6]
        for col in centerColumns {
            if gameState[0][col] == 0 {
                return col
            }
        }
        
        return nil
    }
    
    private func findWinningMove(_ gameState: [[Int]], for player: Int) -> Int? {
        for col in 0..<cols {
            if gameState[0][col] == 0 {
                let testState = makeMove(gameState, column: col, player: player)
                if getWinner(testState) == player {
                    return col
                }
            }
        }
        return nil
    }
    
    private func findSetupMove(_ gameState: [[Int]]) -> Int? {
        // Look for moves that create multiple winning opportunities
        for col in 0..<cols {
            if gameState[0][col] == 0 {
                let testState = makeMove(gameState, column: col, player: aiPlayer)
                let threats = countThreats(testState, for: aiPlayer)
                
                if threats >= 2 {
                    return col
                }
            }
        }
        return nil
    }
    
    private func countThreats(_ gameState: [[Int]], for player: Int) -> Int {
        var threats = 0
        
        // Count positions where player can win in one move
        for col in 0..<cols {
            if gameState[0][col] == 0 {
                let testState = makeMove(gameState, column: col, player: player)
                if getWinner(testState) == player {
                    threats += 1
                }
            }
        }
        
        return threats
    }
    
    // Advanced threat detection
    private func evaluateThreats(_ gameState: [[Int]]) -> Int {
        let aiThreats = countAllThreats(gameState, for: aiPlayer)
        let humanThreats = countAllThreats(gameState, for: humanPlayer)
        
        return aiThreats * 50 - humanThreats * 60 // Blocking is slightly more important
    }
    
    private func countAllThreats(_ gameState: [[Int]], for player: Int) -> Int {
        var threats = 0
        
        // Count all potential 4-in-a-row positions with 3 pieces
        for row in 0..<rows {
            for col in 0..<cols {
                // Horizontal
                if col <= cols - 4 {
                    let window = [gameState[row][col], gameState[row][col + 1], gameState[row][col + 2], gameState[row][col + 3]]
                    if isThreateningWindow(window, for: player) {
                        threats += 1
                    }
                }
                
                // Vertical
                if row <= rows - 4 {
                    let window = [gameState[row][col], gameState[row + 1][col], gameState[row + 2][col], gameState[row + 3][col]]
                    if isThreateningWindow(window, for: player) {
                        threats += 1
                    }
                }
                
                // Diagonals
                if row <= rows - 4 && col <= cols - 4 {
                    let window = [gameState[row][col], gameState[row + 1][col + 1], gameState[row + 2][col + 2], gameState[row + 3][col + 3]]
                    if isThreateningWindow(window, for: player) {
                        threats += 1
                    }
                }
                
                if row <= rows - 4 && col >= 3 {
                    let window = [gameState[row][col], gameState[row + 1][col - 1], gameState[row + 2][col - 2], gameState[row + 3][col - 3]]
                    if isThreateningWindow(window, for: player) {
                        threats += 1
                    }
                }
            }
        }
        
        return threats
    }
    
    private func isThreateningWindow(_ window: [Int], for player: Int) -> Bool {
        let playerCount = window.filter { $0 == player }.count
        let emptyCount = window.filter { $0 == 0 }.count
        let opponentCount = window.filter { $0 != 0 && $0 != player }.count
        
        return playerCount == 3 && emptyCount == 1 && opponentCount == 0
    }
}