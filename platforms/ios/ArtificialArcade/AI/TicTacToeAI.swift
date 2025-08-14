//
//  TicTacToeAI.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation

class TicTacToeAI: BaseAI, MinimaxAI {
    typealias GameState = [[String]]
    typealias Move = TicTacToeMove
    
    private let aiSymbol: String
    private let humanSymbol: String
    
    init(difficulty: AIDifficulty, aiSymbol: String = "O", humanSymbol: String = "X") {
        self.aiSymbol = aiSymbol
        self.humanSymbol = humanSymbol
        super.init(difficulty: difficulty)
    }
    
    func getBestMove(for gameState: [[String]]) -> TicTacToeMove {
        let depth = getGameDepth()
        let (_, bestMove) = minimax(gameState: gameState, depth: depth, isMaximizing: true, alpha: Int.min, beta: Int.max)
        
        // Apply difficulty-based errors
        if let move = bestMove, shouldMakeError() {
            let alternatives = getPossibleMoves(gameState).filter { 
                $0.row != move.row || $0.col != move.col 
            }
            
            if !alternatives.isEmpty {
                return AIMoveSelector.addRandomVariation(to: move, alternatives: alternatives, difficulty: difficulty)
            }
        }
        
        return bestMove ?? getRandomMove(for: gameState)
    }
    
    func getBestMove(for gameState: [[String]], playerSymbol: String) -> TicTacToeMove? {
        let depth = getGameDepth()
        let (_, bestMove) = minimax(gameState: gameState, depth: depth, isMaximizing: true, alpha: Int.min, beta: Int.max)
        return bestMove
    }
    
    func minimax(gameState: [[String]], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> (score: Int, move: TicTacToeMove?) {
        // Check terminal states
        if let result = checkGameEnd(gameState) {
            switch result {
            case .win:
                return isMaximizing ? (-10 + depth, nil) : (10 - depth, nil)
            case .draw:
                return (0, nil)
            default:
                return (0, nil)
            }
        }
        
        if depth == 0 {
            return (evaluatePosition(gameState), nil)
        }
        
        var alpha = alpha
        var beta = beta
        var bestMove: TicTacToeMove?
        
        if isMaximizing {
            var maxScore = Int.min
            
            for move in getPossibleMoves(gameState) {
                var newState = gameState
                newState[move.row][move.col] = aiSymbol
                
                let (score, _) = minimax(gameState: newState, depth: depth - 1, isMaximizing: false, alpha: alpha, beta: beta)
                
                if score > maxScore {
                    maxScore = score
                    bestMove = move
                }
                
                alpha = max(alpha, score)
                if beta <= alpha {
                    break // Beta cutoff
                }
            }
            
            return (maxScore, bestMove)
        } else {
            var minScore = Int.max
            
            for move in getPossibleMoves(gameState) {
                var newState = gameState
                newState[move.row][move.col] = humanSymbol
                
                let (score, _) = minimax(gameState: newState, depth: depth - 1, isMaximizing: true, alpha: alpha, beta: beta)
                
                if score < minScore {
                    minScore = score
                    bestMove = move
                }
                
                beta = min(beta, score)
                if beta <= alpha {
                    break // Alpha cutoff
                }
            }
            
            return (minScore, bestMove)
        }
    }
    
    func evaluatePosition(_ gameState: [[String]]) -> Int {
        var score = 0
        
        // Evaluate rows, columns, and diagonals
        score += evaluateLines(gameState)
        
        // Center control bonus
        if gameState[1][1] == aiSymbol {
            score += 3
        } else if gameState[1][1] == humanSymbol {
            score -= 3
        }
        
        // Corner control bonus
        let corners = [(0,0), (0,2), (2,0), (2,2)]
        for (row, col) in corners {
            if gameState[row][col] == aiSymbol {
                score += 2
            } else if gameState[row][col] == humanSymbol {
                score -= 2
            }
        }
        
        return score
    }
    
    private func evaluateLines(_ gameState: [[String]]) -> Int {
        var score = 0
        
        // Check all lines (rows, columns, diagonals)
        let lines = getAllLines(gameState)
        
        for line in lines {
            score += evaluateLine(line)
        }
        
        return score
    }
    
    private func getAllLines(_ gameState: [[String]]) -> [[String]] {
        var lines: [[String]] = []
        
        // Rows
        for row in 0..<3 {
            lines.append([gameState[row][0], gameState[row][1], gameState[row][2]])
        }
        
        // Columns
        for col in 0..<3 {
            lines.append([gameState[0][col], gameState[1][col], gameState[2][col]])
        }
        
        // Diagonals
        lines.append([gameState[0][0], gameState[1][1], gameState[2][2]])
        lines.append([gameState[0][2], gameState[1][1], gameState[2][0]])
        
        return lines
    }
    
    private func evaluateLine(_ line: [String]) -> Int {
        let aiCount = line.filter { $0 == aiSymbol }.count
        let humanCount = line.filter { $0 == humanSymbol }.count
        let emptyCount = line.filter { $0.isEmpty }.count
        
        if aiCount == 3 { return 100 }
        if humanCount == 3 { return -100 }
        
        if aiCount == 2 && emptyCount == 1 { return 10 }
        if humanCount == 2 && emptyCount == 1 { return -10 }
        
        if aiCount == 1 && emptyCount == 2 { return 1 }
        if humanCount == 1 && emptyCount == 2 { return -1 }
        
        return 0
    }
    
    func getGameDepth() -> Int {
        return difficulty.ticTacToeDepth
    }
    
    private func getPossibleMoves(_ gameState: [[String]]) -> [TicTacToeMove] {
        var moves: [TicTacToeMove] = []
        
        for row in 0..<3 {
            for col in 0..<3 {
                if gameState[row][col].isEmpty {
                    moves.append(TicTacToeMove(row: row, col: col, symbol: aiSymbol))
                }
            }
        }
        
        return moves
    }
    
    private func getRandomMove(for gameState: [[String]]) -> TicTacToeMove {
        let possibleMoves = getPossibleMoves(gameState)
        return possibleMoves.randomElement() ?? TicTacToeMove(row: 0, col: 0, symbol: aiSymbol)
    }
    
    private func checkGameEnd(_ gameState: [[String]]) -> GameResult? {
        // Check for wins
        if checkWin(gameState, for: aiSymbol) || checkWin(gameState, for: humanSymbol) {
            return .win
        }
        
        // Check for draw
        let emptySpaces = gameState.flatMap { $0 }.filter { $0.isEmpty }
        if emptySpaces.isEmpty {
            return .draw
        }
        
        return nil
    }
    
    private func checkWin(_ gameState: [[String]], for symbol: String) -> Bool {
        // Check rows
        for row in 0..<3 {
            if gameState[row][0] == symbol && gameState[row][1] == symbol && gameState[row][2] == symbol {
                return true
            }
        }
        
        // Check columns
        for col in 0..<3 {
            if gameState[0][col] == symbol && gameState[1][col] == symbol && gameState[2][col] == symbol {
                return true
            }
        }
        
        // Check diagonals
        if gameState[0][0] == symbol && gameState[1][1] == symbol && gameState[2][2] == symbol {
            return true
        }
        if gameState[0][2] == symbol && gameState[1][1] == symbol && gameState[2][0] == symbol {
            return true
        }
        
        return false
    }
}

// MARK: - Strategic Move Patterns
extension TicTacToeAI {
    private func getStrategicMove(_ gameState: [[String]]) -> TicTacToeMove? {
        // 1. Try to win immediately
        if let winMove = findWinningMove(gameState, for: aiSymbol) {
            return winMove
        }
        
        // 2. Block opponent from winning
        if let blockMove = findWinningMove(gameState, for: humanSymbol) {
            return TicTacToeMove(row: blockMove.row, col: blockMove.col, symbol: aiSymbol)
        }
        
        // 3. Take center if available
        if gameState[1][1].isEmpty {
            return TicTacToeMove(row: 1, col: 1, symbol: aiSymbol)
        }
        
        // 4. Take corners
        let corners = [(0,0), (0,2), (2,0), (2,2)]
        for (row, col) in corners {
            if gameState[row][col].isEmpty {
                return TicTacToeMove(row: row, col: col, symbol: aiSymbol)
            }
        }
        
        // 5. Take sides
        let sides = [(0,1), (1,0), (1,2), (2,1)]
        for (row, col) in sides {
            if gameState[row][col].isEmpty {
                return TicTacToeMove(row: row, col: col, symbol: aiSymbol)
            }
        }
        
        return nil
    }
    
    private func findWinningMove(_ gameState: [[String]], for symbol: String) -> TicTacToeMove? {
        for row in 0..<3 {
            for col in 0..<3 {
                if gameState[row][col].isEmpty {
                    var testState = gameState
                    testState[row][col] = symbol
                    
                    if checkWin(testState, for: symbol) {
                        return TicTacToeMove(row: row, col: col, symbol: symbol)
                    }
                }
            }
        }
        return nil
    }
}