//
//  ConnectFourScene.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import SpriteKit

class ConnectFourScene: SKScene {
    
    private let ROWS = 6
    private let COLS = 7
    private let PLAYER = 1
    private let AI = 2
    private let EMPTY = 0
    
    private var board: [[Int]] = []
    private var currentPlayer = 1
    private var gameOver = false
    private var isPlayerTurn = true
    private var gameMode: GameMode = .playerVsAI
    
    enum GameMode {
        case playerVsAI
        case twoPlayer
    }
    
    private let cellSize: CGFloat = 45
    private var boardNodes: [[SKShapeNode]] = []
    private var columnButtons: [SKShapeNode] = []
    
    private var titleLabel: SKLabelNode!
    private var statusLabel: SKLabelNode!
    private var backButton: SKLabelNode!
    private var newGameButton: SKLabelNode!
    private var gameModeButton: SKLabelNode!
    private var difficultyButton: SKLabelNode!
    private var aiThinkingLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupUI()
        setupBoard()
        startNewGame()
    }
    
    private func setupUI() {
        backgroundColor = ColorPalettes.ConnectFour.background
        
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "🌅 SUNSET CONNECT FOUR 🌅"
        titleLabel.fontSize = 32
        titleLabel.fontColor = ColorPalettes.ConnectFour.text
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 270)
        addChild(titleLabel)
        
        statusLabel = SKLabelNode(fontNamed: "Helvetica")
        statusLabel.text = "Your turn! Drop a red piece"
        statusLabel.fontSize = 20
        statusLabel.fontColor = ColorPalettes.ConnectFour.text
        statusLabel.position = CGPoint(x: frame.midX, y: frame.midY + 230)
        addChild(statusLabel)
        
        aiThinkingLabel = SKLabelNode(fontNamed: "Helvetica")
        aiThinkingLabel.text = "🤖 AI is thinking..."
        aiThinkingLabel.fontSize = 18
        aiThinkingLabel.fontColor = ColorPalettes.ConnectFour.player2
        aiThinkingLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        aiThinkingLabel.alpha = 0
        addChild(aiThinkingLabel)
        
        backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "← Back to Menu"
        backButton.fontSize = 16
        backButton.fontColor = ColorPalettes.ConnectFour.text
        backButton.position = CGPoint(x: frame.midX - 100, y: frame.midY - 280)
        backButton.name = "back"
        addChild(backButton)
        
        newGameButton = SKLabelNode(fontNamed: "Helvetica")
        newGameButton.text = "🎮 New Game"
        newGameButton.fontSize = 16
        newGameButton.fontColor = ColorPalettes.ConnectFour.player2
        newGameButton.position = CGPoint(x: frame.midX + 100, y: frame.midY - 280)
        newGameButton.name = "newGame"
        addChild(newGameButton)
        
        gameModeButton = SKLabelNode(fontNamed: "Helvetica")
        gameModeButton.text = "🤖 vs AI"
        gameModeButton.fontSize = 14
        gameModeButton.fontColor = ColorPalettes.ConnectFour.player1
        gameModeButton.position = CGPoint(x: frame.midX - 70, y: frame.midY - 280)
        gameModeButton.name = "gameMode"
        addChild(gameModeButton)
        
        // AI Difficulty button
        difficultyButton = SKLabelNode(fontNamed: "Helvetica")
        updateDifficultyButtonText()
        difficultyButton.fontSize = 12
        difficultyButton.fontColor = ColorPalettes.ConnectFour.player2
        difficultyButton.position = CGPoint(x: frame.midX + 70, y: frame.midY - 280)
        difficultyButton.name = "difficulty"
        addChild(difficultyButton)
    }
    
    private func setupBoard() {
        board = Array(repeating: Array(repeating: EMPTY, count: COLS), count: ROWS)
        boardNodes = Array(repeating: Array(repeating: SKShapeNode(), count: COLS), count: ROWS)
        columnButtons = []
        
        let boardWidth = CGFloat(COLS) * cellSize
        let boardHeight = CGFloat(ROWS) * cellSize
        let startX = frame.midX - boardWidth / 2 + cellSize / 2
        let startY = frame.midY + boardHeight / 2 - cellSize / 2
        
        // Create board background
        let boardBackground = SKShapeNode(rectOf: CGSize(width: boardWidth + 10, height: boardHeight + 10))
        boardBackground.fillColor = ColorPalettes.ConnectFour.board
        boardBackground.strokeColor = ColorPalettes.ConnectFour.boardHighlight
        boardBackground.lineWidth = 3
        boardBackground.glowWidth = 2
        boardBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(boardBackground)
        
        // Create cells
        for row in 0..<ROWS {
            for col in 0..<COLS {
                let cell = SKShapeNode(circleOfRadius: cellSize / 2 - 2)
                cell.fillColor = ColorPalettes.ConnectFour.emptyCell
                cell.strokeColor = ColorPalettes.ConnectFour.boardHighlight
                cell.lineWidth = 2
                cell.position = CGPoint(x: startX + CGFloat(col) * cellSize,
                                      y: startY - CGFloat(row) * cellSize)
                addChild(cell)
                boardNodes[row][col] = cell
            }
        }
        
        // Create column buttons
        for col in 0..<COLS {
            let button = SKShapeNode(rectOf: CGSize(width: cellSize - 5, height: 30))
            button.fillColor = ColorPalettes.ConnectFour.columnHover
            button.strokeColor = ColorPalettes.ConnectFour.boardHighlight
            button.lineWidth = 2
            button.position = CGPoint(x: startX + CGFloat(col) * cellSize,
                                    y: startY + cellSize)
            button.name = "column_\(col)"
            addChild(button)
            columnButtons.append(button)
            
            // Add column number label
            let colLabel = SKLabelNode(fontNamed: "Helvetica")
            colLabel.text = "\(col + 1)"
            colLabel.fontSize = 16
            colLabel.fontColor = ColorPalettes.ConnectFour.text
            colLabel.position = button.position
            colLabel.verticalAlignmentMode = .center
            addChild(colLabel)
        }
    }
    
    private func startNewGame() {
        board = Array(repeating: Array(repeating: EMPTY, count: COLS), count: ROWS)
        currentPlayer = PLAYER
        gameOver = false
        isPlayerTurn = true
        
        // Clear visual board
        for row in 0..<ROWS {
            for col in 0..<COLS {
                boardNodes[row][col].fillColor = ColorPalettes.ConnectFour.emptyCell
                boardNodes[row][col].removeAllActions()
            }
        }
        
        // Reset column buttons
        for button in columnButtons {
            button.fillColor = ColorPalettes.ConnectFour.columnHover
        }
        
        updateStatus()
    }
    
    private func updateStatus() {
        if gameOver {
            return
        }
        
        if gameMode == .twoPlayer {
            let playerName = currentPlayer == PLAYER ? "Player 1" : "Player 2"
            let color = currentPlayer == PLAYER ? "orange" : "gold"
            statusLabel.text = "\(playerName)'s turn! Drop a \(color) piece"
            statusLabel.fontColor = currentPlayer == PLAYER ? ColorPalettes.ConnectFour.player1 : ColorPalettes.ConnectFour.player2
            aiThinkingLabel.alpha = 0
        } else {
            if isPlayerTurn {
                statusLabel.text = "🌅 Your turn! Drop an orange piece"
                statusLabel.fontColor = ColorPalettes.ConnectFour.player1
                aiThinkingLabel.alpha = 0
            } else {
                statusLabel.text = "🤖 AI's turn"
                statusLabel.fontColor = ColorPalettes.ConnectFour.player2
                aiThinkingLabel.alpha = 1
            }
        }
    }
    
    private func dropPiece(column: Int) -> Bool {
        guard !gameOver && isValidMove(column: column) else { return false }
        
        for row in (0..<ROWS).reversed() {
            if board[row][column] == EMPTY {
                board[row][column] = currentPlayer
                
                let color = currentPlayer == PLAYER ? ColorPalettes.ConnectFour.player1 : ColorPalettes.ConnectFour.player2
                boardNodes[row][column].fillColor = color
                boardNodes[row][column].strokeColor = color
                boardNodes[row][column].lineWidth = 2
                
                // Add piece drop glow effect
                ColorPalettes.addGlowEffect(to: boardNodes[row][column], color: color, radius: 8)
                
                // Animate piece drop
                let originalPosition = boardNodes[row][column].position
                boardNodes[row][column].position.y += 200
                let dropAction = SKAction.moveTo(y: originalPosition.y, duration: 0.3)
                dropAction.timingMode = .easeOut
                boardNodes[row][column].run(dropAction)
                
                return true
            }
        }
        return false
    }
    
    private func isValidMove(column: Int) -> Bool {
        return column >= 0 && column < COLS && board[0][column] == EMPTY
    }
    
    private func checkWin() -> Bool {
        return checkHorizontal() || checkVertical() || checkDiagonal()
    }
    
    private func checkHorizontal() -> Bool {
        for row in 0..<ROWS {
            for col in 0..<COLS - 3 {
                if board[row][col] != EMPTY &&
                   board[row][col] == board[row][col + 1] &&
                   board[row][col] == board[row][col + 2] &&
                   board[row][col] == board[row][col + 3] {
                    highlightWinningCells([(row, col), (row, col + 1), (row, col + 2), (row, col + 3)])
                    return true
                }
            }
        }
        return false
    }
    
    private func checkVertical() -> Bool {
        for col in 0..<COLS {
            for row in 0..<ROWS - 3 {
                if board[row][col] != EMPTY &&
                   board[row][col] == board[row + 1][col] &&
                   board[row][col] == board[row + 2][col] &&
                   board[row][col] == board[row + 3][col] {
                    highlightWinningCells([(row, col), (row + 1, col), (row + 2, col), (row + 3, col)])
                    return true
                }
            }
        }
        return false
    }
    
    private func checkDiagonal() -> Bool {
        // Check diagonal (top-left to bottom-right)
        for row in 0..<ROWS - 3 {
            for col in 0..<COLS - 3 {
                if board[row][col] != EMPTY &&
                   board[row][col] == board[row + 1][col + 1] &&
                   board[row][col] == board[row + 2][col + 2] &&
                   board[row][col] == board[row + 3][col + 3] {
                    highlightWinningCells([(row, col), (row + 1, col + 1), (row + 2, col + 2), (row + 3, col + 3)])
                    return true
                }
            }
        }
        
        // Check diagonal (top-right to bottom-left)
        for row in 0..<ROWS - 3 {
            for col in 3..<COLS {
                if board[row][col] != EMPTY &&
                   board[row][col] == board[row + 1][col - 1] &&
                   board[row][col] == board[row + 2][col - 2] &&
                   board[row][col] == board[row + 3][col - 3] {
                    highlightWinningCells([(row, col), (row + 1, col - 1), (row + 2, col - 2), (row + 3, col - 3)])
                    return true
                }
            }
        }
        return false
    }
    
    private func highlightWinningCells(_ cells: [(Int, Int)]) {
        for (row, col) in cells {
            // Enhanced winning cell effect
            let glowAction = SKAction.sequence([
                SKAction.run {
                    self.boardNodes[row][col].strokeColor = ColorPalettes.ConnectFour.winGlow
                    self.boardNodes[row][col].lineWidth = 4
                    ColorPalettes.addGlowEffect(to: self.boardNodes[row][col], color: ColorPalettes.ConnectFour.winGlow, radius: 15)
                },
                SKAction.scale(to: 1.3, duration: 0.4),
                SKAction.scale(to: 1.1, duration: 0.4)
            ])
            boardNodes[row][col].run(SKAction.repeatForever(glowAction))
        }
    }
    
    private func isBoardFull() -> Bool {
        for col in 0..<COLS {
            if board[0][col] == EMPTY {
                return false
            }
        }
        return true
    }
    
    private func makeAIMove() {
        let bestColumn = getBestMove()
        if dropPiece(column: bestColumn) {
            if checkWin() {
                gameOver = true
                statusLabel.text = "🤖 AI Dominates! 🎆"
                statusLabel.fontColor = ColorPalettes.ConnectFour.player2
                aiThinkingLabel.alpha = 0
                
                // Record AI win
                HighScoreManager.shared.recordConnectFourResult(playerWon: false, vsAI: true)
                UserManager.shared.addExperience(25)
            } else if isBoardFull() {
                gameOver = true
                statusLabel.text = "🤝 Sunset Draw! 🌅"
                statusLabel.fontColor = ColorPalettes.ConnectFour.text
                aiThinkingLabel.alpha = 0
            } else {
                currentPlayer = PLAYER
                isPlayerTurn = true
                updateStatus()
            }
        }
    }
    
    private func getBestMove() -> Int {
        let difficulty = AIDifficultyManager.shared.connectFourDifficulty
        let depth = difficulty.connectFourDepth
        
        // Advanced AI using minimax with alpha-beta pruning
        let (_, bestColumn) = minimax(depth: depth, alpha: Int.min, beta: Int.max, maximizingPlayer: true)
        let column = bestColumn ?? 3 // fallback to center column
        
        // Apply difficulty-based errors
        if AIDifficultyManager.shared.shouldMakeError(for: difficulty) {
            // Get alternative valid moves
            var alternatives: [Int] = []
            for col in 0..<COLS {
                if isValidMove(column: col) && col != column {
                    alternatives.append(col)
                }
            }
            return AIDifficultyManager.shared.getRandomizedMove(bestMove: column, alternatives: alternatives, difficulty: difficulty)
        }
        
        return column
    }
    
    private func minimax(depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool) -> (Int, Int?) {
        let winner = getWinner()
        
        if depth == 0 || winner != nil || isBoardFull() {
            return (evaluateBoard(), nil)
        }
        
        var bestScore = maximizingPlayer ? Int.min : Int.max
        var bestColumn: Int? = nil
        var currentAlpha = alpha
        var currentBeta = beta
        
        for col in 0..<COLS {
            if isValidMove(column: col) {
                // Make move
                let row = getLowestEmptyRow(column: col)
                board[row][col] = maximizingPlayer ? AI : PLAYER
                
                let (score, _) = minimax(depth: depth - 1, alpha: currentAlpha, beta: currentBeta, maximizingPlayer: !maximizingPlayer)
                
                // Undo move
                board[row][col] = EMPTY
                
                if maximizingPlayer {
                    if score > bestScore {
                        bestScore = score
                        bestColumn = col
                    }
                    currentAlpha = max(currentAlpha, score)
                } else {
                    if score < bestScore {
                        bestScore = score
                        bestColumn = col
                    }
                    currentBeta = min(currentBeta, score)
                }
                
                if currentBeta <= currentAlpha {
                    break // Alpha-beta pruning
                }
            }
        }
        
        return (bestScore, bestColumn)
    }
    
    private func getLowestEmptyRow(column: Int) -> Int {
        for row in (0..<ROWS).reversed() {
            if board[row][column] == EMPTY {
                return row
            }
        }
        return -1
    }
    
    private func evaluateBoard() -> Int {
        let winner = getWinner()
        if winner == AI { return 10000 }
        if winner == PLAYER { return -10000 }
        
        var score = 0
        
        // Evaluate all possible 4-in-a-row positions
        for row in 0..<ROWS {
            for col in 0..<COLS {
                // Horizontal
                if col <= COLS - 4 {
                    score += evaluateWindow([board[row][col], board[row][col + 1], board[row][col + 2], board[row][col + 3]])
                }
                
                // Vertical
                if row <= ROWS - 4 {
                    score += evaluateWindow([board[row][col], board[row + 1][col], board[row + 2][col], board[row + 3][col]])
                }
                
                // Diagonal (top-left to bottom-right)
                if row <= ROWS - 4 && col <= COLS - 4 {
                    score += evaluateWindow([board[row][col], board[row + 1][col + 1], board[row + 2][col + 2], board[row + 3][col + 3]])
                }
                
                // Diagonal (top-right to bottom-left)
                if row <= ROWS - 4 && col >= 3 {
                    score += evaluateWindow([board[row][col], board[row + 1][col - 1], board[row + 2][col - 2], board[row + 3][col - 3]])
                }
            }
        }
        
        return score
    }
    
    private func evaluateWindow(_ window: [Int]) -> Int {
        let aiCount = window.filter { $0 == AI }.count
        let playerCount = window.filter { $0 == PLAYER }.count
        let emptyCount = window.filter { $0 == EMPTY }.count
        
        if aiCount == 4 { return 100 }
        if playerCount == 4 { return -100 }
        if aiCount == 3 && emptyCount == 1 { return 10 }
        if playerCount == 3 && emptyCount == 1 { return -10 }
        if aiCount == 2 && emptyCount == 2 { return 2 }
        if playerCount == 2 && emptyCount == 2 { return -2 }
        
        return 0
    }
    
    private func getWinner() -> Int? {
        for row in 0..<ROWS {
            for col in 0..<COLS {
                let player = board[row][col]
                if player == EMPTY { continue }
                
                // Check horizontal
                if col <= COLS - 4 &&
                   board[row][col + 1] == player &&
                   board[row][col + 2] == player &&
                   board[row][col + 3] == player {
                    return player
                }
                
                // Check vertical
                if row <= ROWS - 4 &&
                   board[row + 1][col] == player &&
                   board[row + 2][col] == player &&
                   board[row + 3][col] == player {
                    return player
                }
                
                // Check diagonal
                if row <= ROWS - 4 && col <= COLS - 4 &&
                   board[row + 1][col + 1] == player &&
                   board[row + 2][col + 2] == player &&
                   board[row + 3][col + 3] == player {
                    return player
                }
                
                if row <= ROWS - 4 && col >= 3 &&
                   board[row + 1][col - 1] == player &&
                   board[row + 2][col - 2] == player &&
                   board[row + 3][col - 3] == player {
                    return player
                }
            }
        }
        return nil
    }
    
    private func toggleGameMode() {
        gameMode = gameMode == .playerVsAI ? .twoPlayer : .playerVsAI
        gameModeButton.text = gameMode == .playerVsAI ? "🤖 vs AI" : "👥 2 Players"
        startNewGame()
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
        
        if nodeName == "newGame" {
            startNewGame()
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
        
        if nodeName.hasPrefix("column_") && !gameOver && (gameMode == .twoPlayer || isPlayerTurn) {
            let columnString = nodeName.replacingOccurrences(of: "column_", with: "")
            if let column = Int(columnString) {
                if dropPiece(column: column) {
                    if checkWin() {
                        gameOver = true
                        if gameMode == .twoPlayer {
                            let winnerName = currentPlayer == PLAYER ? "Player 1" : "Player 2"
                            statusLabel.text = "🎆 \(winnerName) Rules the Sunset! 🌅"
                            statusLabel.fontColor = currentPlayer == PLAYER ? ColorPalettes.ConnectFour.player1 : ColorPalettes.ConnectFour.player2
                        } else {
                            statusLabel.text = "🎆 Sunset Victory! You Win! 🌅"
                            statusLabel.fontColor = ColorPalettes.ConnectFour.player1
                            
                            // Record player win and achievements
                            HighScoreManager.shared.recordConnectFourResult(playerWon: true, vsAI: true)
                            AchievementManager.shared.recordWin(
                                game: "connectfour",
                                streak: getCurrentWinStreak(),
                                isAI: true,
                                difficulty: AIDifficultyManager.shared.connectFourDifficulty
                            )
                            AchievementManager.shared.checkAchievement("c4_first_win")
                            UserManager.shared.addExperience(100)
                        }
                        
                        // Add victory effects
                        addVictoryEffect()
                    } else if isBoardFull() {
                        gameOver = true
                        statusLabel.text = "🤝 Sunset Draw! 🌅"
                        statusLabel.fontColor = ColorPalettes.ConnectFour.text
                    } else {
                        if gameMode == .twoPlayer {
                            currentPlayer = currentPlayer == PLAYER ? AI : PLAYER
                            updateStatus()
                        } else {
                            currentPlayer = AI
                            isPlayerTurn = false
                            updateStatus()
                            
                            // AI makes move after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.makeAIMove()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addVictoryEffect() {
        // Create sunset particle effect for victory
        for i in 0..<20 {
            let delay = Double(i) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
                particle.fillColor = [
                    ColorPalettes.ConnectFour.player1,
                    ColorPalettes.ConnectFour.player2,
                    ColorPalettes.ConnectFour.winGlow
                ].randomElement()?.withAlphaComponent(0.8) ?? ColorPalettes.ConnectFour.player1.withAlphaComponent(0.8)
                particle.strokeColor = SKColor.clear
                particle.position = CGPoint(
                    x: CGFloat.random(in: 0...self.frame.width),
                    y: self.frame.maxY + 50
                )
                particle.zPosition = 100
                self.addChild(particle)
                
                let fallAction = SKAction.sequence([
                    SKAction.group([
                        SKAction.moveBy(x: CGFloat.random(in: -100...100), y: -self.frame.height - 100, duration: 4.0),
                        SKAction.rotate(byAngle: CGFloat.random(in: -2...2), duration: 4.0),
                        SKAction.fadeOut(withDuration: 4.0)
                    ]),
                    SKAction.removeFromParent()
                ])
                particle.run(fallAction)
            }
        }
        
        // Add screen gradient effect
        if let gradientTexture = ColorPalettes.createGradientTexture(
            colors: [
                ColorPalettes.ConnectFour.player1.withAlphaComponent(0.2),
                ColorPalettes.ConnectFour.player2.withAlphaComponent(0.2),
                SKColor.clear
            ],
            size: frame.size
        ) {
            let gradientOverlay = SKSpriteNode(texture: gradientTexture)
            gradientOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
            gradientOverlay.zPosition = 99
            addChild(gradientOverlay)
            
            let fadeAction = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.fadeOut(withDuration: 2.0),
                SKAction.removeFromParent()
            ])
            gradientOverlay.run(fadeAction)
        }
    }
    
    private func updateDifficultyButtonText() {
        let difficulty = AIDifficultyManager.shared.connectFourDifficulty
        difficultyButton.text = difficulty.rawValue
    }
    
    private func cycleDifficulty() {
        let current = AIDifficultyManager.shared.connectFourDifficulty
        let allDifficulties = AIDifficulty.allCases
        
        if let currentIndex = allDifficulties.firstIndex(of: current) {
            let nextIndex = (currentIndex + 1) % allDifficulties.count
            AIDifficultyManager.shared.connectFourDifficulty = allDifficulties[nextIndex]
            updateDifficultyButtonText()
            
            // Show difficulty change message
            statusLabel.text = "🌅 AI Difficulty: \\(allDifficulties[nextIndex].displayName)"
            statusLabel.fontColor = ColorPalettes.ConnectFour.player2
            
            // Reset the game with new difficulty
            startNewGame()
            
            // Clear message after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.statusLabel.text?.contains("AI Difficulty") == true {
                    self.updateStatus()
                }
            }
        }
    }
    
    private func getCurrentWinStreak() -> Int {
        return UserDefaults.standard.integer(forKey: "ConnectFourWinStreak")
    }
    
    private func updateWinStreak(playerWon: Bool) {
        if playerWon {
            let currentStreak = getCurrentWinStreak() + 1
            UserDefaults.standard.set(currentStreak, forKey: "ConnectFourWinStreak")
        } else {
            UserDefaults.standard.set(0, forKey: "ConnectFourWinStreak")
        }
    }
}