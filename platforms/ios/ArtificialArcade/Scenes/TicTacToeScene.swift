//
//  TicTacToeScene.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import SpriteKit

class TicTacToeScene: SKScene {
    
    private var board: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: 3)
    private var currentPlayer = "X"
    private var gameOver = false
    private var isPlayerTurn = true
    private var gameMode: GameMode = .playerVsAI
    
    enum GameMode {
        case playerVsAI
        case twoPlayer
    }
    
    private var titleLabel: SKLabelNode!
    private var statusLabel: SKLabelNode!
    private var backButton: SKLabelNode!
    private var restartButton: SKLabelNode!
    private var gameModeButton: SKLabelNode!
    private var difficultyButton: SKLabelNode!
    private var boardNodes: [[SKShapeNode]] = []
    private var cellLabels: [[SKLabelNode]] = []
    
    override func didMove(to view: SKView) {
        setupUI()
        setupBoard()
    }
    
    private func setupUI() {
        backgroundColor = ColorPalettes.TicTacToe.background
        
        // Title
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "⚡ TIC-TAC-TOE ⚡"
        titleLabel.fontSize = 32
        titleLabel.fontColor = ColorPalettes.TicTacToe.text
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 250)
        addChild(titleLabel)
        
        // Status
        statusLabel = SKLabelNode(fontNamed: "Helvetica")
        statusLabel.text = "Your turn! (X)"
        statusLabel.fontSize = 22
        statusLabel.fontColor = ColorPalettes.TicTacToe.text
        statusLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        addChild(statusLabel)
        
        // Back button
        backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "← Back to Menu"
        backButton.fontSize = 18
        backButton.fontColor = ColorPalettes.TicTacToe.accent
        backButton.position = CGPoint(x: frame.midX - 120, y: frame.midY - 280)
        backButton.name = "back"
        addChild(backButton)
        
        // Restart button
        restartButton = SKLabelNode(fontNamed: "Helvetica")
        restartButton.text = "🔄 Restart"
        restartButton.fontSize = 18
        restartButton.fontColor = ColorPalettes.TicTacToe.accent
        restartButton.position = CGPoint(x: frame.midX + 120, y: frame.midY - 280)
        restartButton.name = "restart"
        addChild(restartButton)
        
        // Game mode button
        gameModeButton = SKLabelNode(fontNamed: "Helvetica")
        gameModeButton.text = "🤖 vs AI"
        gameModeButton.fontSize = 16
        gameModeButton.fontColor = ColorPalettes.TicTacToe.playerO
        gameModeButton.position = CGPoint(x: frame.midX - 60, y: frame.midY - 280)
        gameModeButton.name = "gameMode"
        addChild(gameModeButton)
        
        // AI Difficulty button
        difficultyButton = SKLabelNode(fontNamed: "Helvetica")
        updateDifficultyButtonText()
        difficultyButton.fontSize = 14
        difficultyButton.fontColor = ColorPalettes.TicTacToe.accent
        difficultyButton.position = CGPoint(x: frame.midX + 60, y: frame.midY - 280)
        difficultyButton.name = "difficulty"
        addChild(difficultyButton)
    }
    
    private func setupBoard() {
        let cellSize: CGFloat = 80
        let boardSize = cellSize * 3
        let startX = frame.midX - boardSize / 2 + cellSize / 2
        let startY = frame.midY + cellSize / 2
        
        boardNodes = Array(repeating: Array(repeating: SKShapeNode(), count: 3), count: 3)
        cellLabels = Array(repeating: Array(repeating: SKLabelNode(), count: 3), count: 3)
        
        for row in 0..<3 {
            for col in 0..<3 {
                // Create cell background
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize - 4, height: cellSize - 4))
                cell.fillColor = ColorPalettes.TicTacToe.background
                cell.strokeColor = ColorPalettes.TicTacToe.gridLine
                cell.lineWidth = 3
                cell.position = CGPoint(x: startX + CGFloat(col) * cellSize,
                                      y: startY - CGFloat(row) * cellSize)
                cell.name = "cell_\(row)_\(col)"
                addChild(cell)
                boardNodes[row][col] = cell
                
                // Create cell label
                let label = SKLabelNode(fontNamed: "Helvetica-Bold")
                label.text = ""
                label.fontSize = 40
                label.fontColor = ColorPalettes.TicTacToe.text
                label.position = cell.position
                label.verticalAlignmentMode = .center
                addChild(label)
                cellLabels[row][col] = label
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = nodes(at: location).first
        
        guard let nodeName = touchedNode?.name else { return }
        
        if nodeName == "back" {
            let scene = ArcadeMenuScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
            return
        }
        
        if nodeName == "restart" {
            restartGame()
            return
        }
        
        if nodeName == "gameMode" {
            toggleGameMode()
            return
        }
        
        if nodeName == "difficulty" {
            cycleDifficulty()
            return
        }
        
        if nodeName.hasPrefix("cell_") && !gameOver {
            let components = nodeName.components(separatedBy: "_")
            if components.count == 3,
               let row = Int(components[1]),
               let col = Int(components[2]) {
                makeMove(row: row, col: col)
            }
        }
    }
    
    private func makeMove(row: Int, col: Int) {
        guard board[row][col] == "" else { return }
        
        board[row][col] = currentPlayer
        cellLabels[row][col].text = currentPlayer
        cellLabels[row][col].fontColor = currentPlayer == "X" ? ColorPalettes.TicTacToe.playerX : ColorPalettes.TicTacToe.playerO
        
        // Add cell highlight effect
        boardNodes[row][col].fillColor = ColorPalettes.TicTacToe.cellHighlight
        let fadeBack = SKAction.colorize(with: ColorPalettes.TicTacToe.background, colorBlendFactor: 1.0, duration: 0.5)
        boardNodes[row][col].run(fadeBack)
        
        if checkWin() {
            gameOver = true
            statusLabel.text = "🎉 \(currentPlayer) Wins! 🎉"
            statusLabel.fontColor = ColorPalettes.TicTacToe.accent
            
            // Record the result and achievements
            let playerWon = (gameMode == .playerVsAI && currentPlayer == "X") || (gameMode == .twoPlayer)
            HighScoreManager.shared.recordTicTacToeResult(playerWon: playerWon, vsAI: gameMode == .playerVsAI)
            
            if gameMode == .playerVsAI {
                AchievementManager.shared.recordWin(
                    game: "tictactoe",
                    streak: getCurrentWinStreak(),
                    isAI: true,
                    difficulty: AIDifficultyManager.shared.ticTacToeDifficulty
                )
                
                // Special achievements
                if playerWon {
                    AchievementManager.shared.checkAchievement("ttt_first_win")
                    UserManager.shared.addExperience(50)
                }
            }
            
            // Add win line effect
            highlightWinningLine()
        } else if isBoardFull() {
            gameOver = true
            statusLabel.text = "🤝 It's a Draw! 🤝"
            statusLabel.fontColor = ColorPalettes.TicTacToe.accent
            
            // Record the draw
            HighScoreManager.shared.recordTicTacToeResult(playerWon: false, vsAI: gameMode == .playerVsAI)
            UserManager.shared.addExperience(25)
        } else {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
            
            if gameMode == .twoPlayer {
                let playerName = currentPlayer == "X" ? "Player 1" : "Player 2"
                statusLabel.text = "\(playerName)'s turn! (\(currentPlayer))"
                statusLabel.fontColor = currentPlayer == "X" ? ColorPalettes.TicTacToe.playerX : ColorPalettes.TicTacToe.playerO
            } else {
                isPlayerTurn = currentPlayer == "X"
                
                if isPlayerTurn {
                    statusLabel.text = "⚡ Your turn! (X)"
                    statusLabel.fontColor = ColorPalettes.TicTacToe.playerX
                } else {
                    statusLabel.text = "🤖 AI thinking..."
                    statusLabel.fontColor = ColorPalettes.TicTacToe.playerO
                    
                    // AI makes move after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.makeAIMove()
                    }
                }
            }
        }
    }
    
    private func makeAIMove() {
        guard !gameOver else { return }
        
        let move = getBestMove()
        if let (row, col) = move {
            makeMove(row: row, col: col)
        }
    }
    
    private func getBestMove() -> (Int, Int)? {
        let difficulty = AIDifficultyManager.shared.ticTacToeDifficulty
        let depth = difficulty.ticTacToeDepth
        
        // Get the best move using minimax
        let (_, bestMove) = minimax(depth: depth, isMaximizing: true)
        
        // Apply difficulty-based errors
        if let best = bestMove, AIDifficultyManager.shared.shouldMakeError(for: difficulty) {
            // Get alternative moves (not the best one)
            var alternatives: [(Int, Int)] = []
            for row in 0..<3 {
                for col in 0..<3 {
                    if board[row][col] == "" && (row, col) != best {
                        alternatives.append((row, col))
                    }
                }
            }
            return AIDifficultyManager.shared.getRandomizedMove(bestMove: best, alternatives: alternatives, difficulty: difficulty)
        }
        
        return bestMove
    }
    
    private func minimax(depth: Int, isMaximizing: Bool) -> (Int, (Int, Int)?) {
        if checkWinForPlayer("O") { return (10 - (9 - depth), nil) }  // AI wins
        if checkWinForPlayer("X") { return (-10 + (9 - depth), nil) } // Player wins
        if isBoardFull() || depth == 0 { return (0, nil) }            // Draw or depth limit
        
        var bestScore = isMaximizing ? Int.min : Int.max
        var bestMove: (Int, Int)? = nil
        
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == "" {
                    // Make move
                    board[row][col] = isMaximizing ? "O" : "X"
                    
                    // Recursive minimax call
                    let (score, _) = minimax(depth: depth - 1, isMaximizing: !isMaximizing)
                    
                    // Undo move
                    board[row][col] = ""
                    
                    // Update best score and move
                    if isMaximizing {
                        if score > bestScore {
                            bestScore = score
                            bestMove = (row, col)
                        }
                    } else {
                        if score < bestScore {
                            bestScore = score
                            bestMove = (row, col)
                        }
                    }
                }
            }
        }
        
        return (bestScore, bestMove)
    }
    
    private func checkWinForPlayer(_ player: String) -> Bool {
        let originalBoard = board
        let originalCurrentPlayer = currentPlayer
        currentPlayer = player
        let result = checkWin()
        board = originalBoard
        currentPlayer = originalCurrentPlayer
        return result
    }
    
    private func checkWin() -> Bool {
        // Check rows
        for row in 0..<3 {
            if board[row][0] != "" && board[row][0] == board[row][1] && board[row][1] == board[row][2] {
                return true
            }
        }
        
        // Check columns
        for col in 0..<3 {
            if board[0][col] != "" && board[0][col] == board[1][col] && board[1][col] == board[2][col] {
                return true
            }
        }
        
        // Check diagonals
        if board[0][0] != "" && board[0][0] == board[1][1] && board[1][1] == board[2][2] {
            return true
        }
        if board[0][2] != "" && board[0][2] == board[1][1] && board[1][1] == board[2][0] {
            return true
        }
        
        return false
    }
    
    private func isBoardFull() -> Bool {
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == "" {
                    return false
                }
            }
        }
        return true
    }
    
    private func toggleGameMode() {
        gameMode = gameMode == .playerVsAI ? .twoPlayer : .playerVsAI
        gameModeButton.text = gameMode == .playerVsAI ? "🤖 vs AI" : "👥 2 Players"
        restartGame()
    }
    
    private func restartGame() {
        board = Array(repeating: Array(repeating: "", count: 3), count: 3)
        currentPlayer = "X"
        gameOver = false
        isPlayerTurn = true
        
        for row in 0..<3 {
            for col in 0..<3 {
                cellLabels[row][col].text = ""
            }
        }
        
        if gameMode == .twoPlayer {
            statusLabel.text = "Player 1's turn! (X)"
            statusLabel.fontColor = ColorPalettes.TicTacToe.playerX
        } else {
            statusLabel.text = "⚡ Your turn! (X)"
            statusLabel.fontColor = ColorPalettes.TicTacToe.playerX
        }
        
        // Reset cell colors and remove win line effects
        for row in 0..<3 {
            for col in 0..<3 {
                boardNodes[row][col].fillColor = ColorPalettes.TicTacToe.background
                boardNodes[row][col].removeAllActions()
            }
        }
        
        // Remove any existing win lines
        children.filter { $0.zPosition == 10 }.forEach { $0.removeFromParent() }
    }
    
    private func highlightWinningLine() {
        let winningCells = getWinningCells()
        for (row, col) in winningCells {
            // Create win line effect
            let winLine = SKShapeNode(rectOf: CGSize(width: 90, height: 6))
            winLine.fillColor = ColorPalettes.TicTacToe.winLine
            winLine.strokeColor = SKColor.clear
            winLine.position = boardNodes[row][col].position
            winLine.zPosition = 10
            addChild(winLine)
            
            // Animate the win line
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            winLine.run(SKAction.repeatForever(pulse))
        }
    }
    
    private func getWinningCells() -> [(Int, Int)] {
        // Check rows
        for row in 0..<3 {
            if board[row][0] != "" && board[row][0] == board[row][1] && board[row][1] == board[row][2] {
                return [(row, 0), (row, 1), (row, 2)]
            }
        }
        
        // Check columns
        for col in 0..<3 {
            if board[0][col] != "" && board[0][col] == board[1][col] && board[1][col] == board[2][col] {
                return [(0, col), (1, col), (2, col)]
            }
        }
        
        // Check diagonals
        if board[0][0] != "" && board[0][0] == board[1][1] && board[1][1] == board[2][2] {
            return [(0, 0), (1, 1), (2, 2)]
        }
        if board[0][2] != "" && board[0][2] == board[1][1] && board[1][1] == board[2][0] {
            return [(0, 2), (1, 1), (2, 0)]
        }
        
        return []
    }
    
    private func updateDifficultyButtonText() {
        let difficulty = AIDifficultyManager.shared.ticTacToeDifficulty
        difficultyButton.text = difficulty.rawValue
    }
    
    private func cycleDifficulty() {
        let current = AIDifficultyManager.shared.ticTacToeDifficulty
        let allDifficulties = AIDifficulty.allCases
        
        if let currentIndex = allDifficulties.firstIndex(of: current) {
            let nextIndex = (currentIndex + 1) % allDifficulties.count
            AIDifficultyManager.shared.ticTacToeDifficulty = allDifficulties[nextIndex]
            updateDifficultyButtonText()
            
            // Show difficulty change message
            statusLabel.text = "🤖 AI Difficulty: \\(allDifficulties[nextIndex].displayName)"
            statusLabel.fontColor = ColorPalettes.TicTacToe.accent
            
            // Reset the game with new difficulty
            restartGame()
            
            // Clear message after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.statusLabel.text?.contains("AI Difficulty") == true {
                    self.statusLabel.text = "⚡ Your turn! (X)"
                    self.statusLabel.fontColor = ColorPalettes.TicTacToe.playerX
                }
            }
        }
    }
    
    private func getCurrentWinStreak() -> Int {
        // Simple win streak tracking - in a real app this would be more sophisticated
        return UserDefaults.standard.integer(forKey: "TicTacToeWinStreak")
    }
    
    private func updateWinStreak(playerWon: Bool) {
        if playerWon {
            let currentStreak = getCurrentWinStreak() + 1
            UserDefaults.standard.set(currentStreak, forKey: "TicTacToeWinStreak")
        } else {
            UserDefaults.standard.set(0, forKey: "TicTacToeWinStreak")
        }
    }
}