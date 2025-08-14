//
//  SnakeScene.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import SpriteKit

class SnakeScene: SKScene {
    
    struct Position {
        var x: Int
        var y: Int
    }
    
    private let gridSize = 20
    private var gridWidth: Int!
    private var gridHeight: Int!
    
    private var snake: [Position] = []
    private var food: Position!
    private var direction: Position = Position(x: 1, y: 0)
    private var nextDirection: Position = Position(x: 1, y: 0)
    
    private var gameRunning = false
    private var score = 0
    private var gameSpeed: TimeInterval = 0.15
    private var lastUpdateTime: TimeInterval = 0
    
    private var titleLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var instructionsLabel: SKLabelNode!
    private var backButton: SKLabelNode!
    private var playButton: SKLabelNode!
    private var gameModeButton: SKLabelNode!
    private var gameBoard: SKShapeNode!
    private var snakeNodes: [SKShapeNode] = []
    private var foodNode: SKShapeNode!
    private var gameMode: GameMode = .single
    private var currentPlayerName = "Player 1"
    private var player1Score = 0
    private var player2Score = 0
    
    enum GameMode {
        case single
        case turnBased // Players take turns, compete for high score
    }
    
    private var swipeGestureUp: UISwipeGestureRecognizer!
    private var swipeGestureDown: UISwipeGestureRecognizer!
    private var swipeGestureLeft: UISwipeGestureRecognizer!
    private var swipeGestureRight: UISwipeGestureRecognizer!
    
    override func didMove(to view: SKView) {
        setupGame()
        setupUI()
        setupGestures()
    }
    
    private func setupGame() {
        gridWidth = Int(frame.width) / gridSize - 4
        gridHeight = Int(frame.height - 200) / gridSize
        
        snake = [
            Position(x: gridWidth / 2, y: gridHeight / 2),
            Position(x: gridWidth / 2 - 1, y: gridHeight / 2),
            Position(x: gridWidth / 2 - 2, y: gridHeight / 2)
        ]
        
        spawnFood()
        score = 0
        gameSpeed = 0.15
        direction = Position(x: 1, y: 0)
        nextDirection = Position(x: 1, y: 0)
    }
    
    private func setupUI() {
        backgroundColor = ColorPalettes.Snake.background
        
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "⚡ MATRIX SNAKE ⚡"
        titleLabel.fontSize = 32
        titleLabel.fontColor = ColorPalettes.Snake.snakeHead
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        addChild(titleLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = ColorPalettes.Snake.score
        scoreLabel.position = CGPoint(x: frame.midX - 80, y: frame.maxY - 100)
        addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        let highScore = HighScoreManager.shared.snakeHighScore
        highScoreLabel.text = "BEST: \(highScore)"
        highScoreLabel.fontSize = 22
        highScoreLabel.fontColor = ColorPalettes.Snake.snakeHead
        highScoreLabel.position = CGPoint(x: frame.midX + 80, y: frame.maxY - 100)
        addChild(highScoreLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = ""
        gameOverLabel.fontSize = 28
        gameOverLabel.fontColor = ColorPalettes.Snake.gameOver
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        gameOverLabel.alpha = 0
        addChild(gameOverLabel)
        
        instructionsLabel = SKLabelNode(fontNamed: "Helvetica")
        instructionsLabel.text = "⚡ ENTER THE MATRIX ⚡\nSwipe to move • Eat data to grow • Avoid system crashes!"
        instructionsLabel.fontSize = 14
        instructionsLabel.fontColor = ColorPalettes.Snake.snakeBody
        instructionsLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        instructionsLabel.numberOfLines = 0
        addChild(instructionsLabel)
        
        playButton = SKLabelNode(fontNamed: "Helvetica-Bold")
        updatePlayButtonText()
        playButton.fontSize = 24
        playButton.fontColor = ColorPalettes.Snake.snakeHead
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        playButton.name = "play"
        addChild(playButton)
        
        backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "← Back to Menu"
        backButton.fontSize = 16
        backButton.fontColor = ColorPalettes.Snake.score
        backButton.position = CGPoint(x: frame.midX - 120, y: frame.minY + 40)
        backButton.name = "back"
        addChild(backButton)
        
        gameModeButton = SKLabelNode(fontNamed: "Helvetica")
        gameModeButton.text = "🎮 Single Player"
        gameModeButton.fontSize = 14
        gameModeButton.fontColor = ColorPalettes.Snake.snakeBody
        gameModeButton.position = CGPoint(x: frame.midX + 80, y: frame.minY + 40)
        gameModeButton.name = "gameMode"
        addChild(gameModeButton)
        
        setupGameBoard()
    }
    
    private func setupGameBoard() {
        gameBoard = SKShapeNode(rectOf: CGSize(width: CGFloat(gridWidth * gridSize), height: CGFloat(gridHeight * gridSize)))
        gameBoard.fillColor = SKColor.clear
        gameBoard.strokeColor = ColorPalettes.Snake.gridLine
        gameBoard.lineWidth = 1
        gameBoard.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        addChild(gameBoard)
    }
    
    private func setupGestures() {
        guard let view = self.view else { return }
        
        swipeGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureUp.direction = .up
        view.addGestureRecognizer(swipeGestureUp)
        
        swipeGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureDown.direction = .down
        view.addGestureRecognizer(swipeGestureDown)
        
        swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureLeft.direction = .left
        view.addGestureRecognizer(swipeGestureLeft)
        
        swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureRight.direction = .right
        view.addGestureRecognizer(swipeGestureRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard gameRunning else { return }
        
        switch gesture.direction {
        case .up:
            if direction.y != -1 { nextDirection = Position(x: 0, y: 1) }
        case .down:
            if direction.y != 1 { nextDirection = Position(x: 0, y: -1) }
        case .left:
            if direction.x != 1 { nextDirection = Position(x: -1, y: 0) }
        case .right:
            if direction.x != -1 { nextDirection = Position(x: 1, y: 0) }
        default:
            break
        }
    }
    
    private func startGame() {
        gameRunning = true
        playButton.alpha = 0
        instructionsLabel.alpha = 0
        gameOverLabel.alpha = 0
        
        // Record game start
        AchievementManager.shared.recordGamePlayed(game: "snake")
        
        renderSnake()
        renderFood()
    }
    
    private func endGame() {
        gameRunning = false
        
        if gameMode == .turnBased {
            if currentPlayerName == "Player 1" {
                player1Score = score
                currentPlayerName = "Player 2"
                gameOverLabel.text = "📊 PLAYER 1 MATRIX SCORE: \(score)\n⚡ PLAYER 2'S TURN!"
                playButton.text = "⚡ PLAYER 2 ENTER MATRIX"
            } else {
                player2Score = score
                let winner = player1Score > player2Score ? "Player 1" : (player2Score > player1Score ? "Player 2" : "It's a tie!")
                gameOverLabel.text = "📊 PLAYER 2 MATRIX SCORE: \(score)\n\(winner == "It's a tie!" ? "🤝 MATRIX TIE!" : "🎆 " + winner + " BREACHED THE MATRIX!")\nP1: \(player1Score) | P2: \(player2Score)"
                playButton.text = "⚡ RESTART MATRIX"
                currentPlayerName = "Player 1"
                player1Score = 0
                player2Score = 0
            }
        } else {
            // Record the score using HighScoreManager
            HighScoreManager.shared.recordSnakeScore(score)
            AchievementManager.shared.checkAchievement("snake_first_score")
            
            // Check various achievements
            if score >= 500 {
                AchievementManager.shared.checkAchievement("snake_high_score", progress: score)
            }
            if gameSpeed <= 0.05 {
                AchievementManager.shared.checkAchievement("snake_speed_demon")
            }
            
            UserManager.shared.addExperience(score / 10)
            
            let highScore = HighScoreManager.shared.snakeHighScore
            if score == highScore && score > 0 {
                highScoreLabel.text = "BEST: \(score)"
                gameOverLabel.text = "🎆 MATRIX BREACHED! 🎆\n⚡ NEW HIGH SCORE: \(score) ⚡"
                
                // Add celebration effect
                addHighScoreEffect()
            } else {
                gameOverLabel.text = "🔴 SYSTEM ERROR 🔴\nSCORE: \(score) | BEST: \(highScore)"
            }
            playButton.text = "⚡ REBOOT MATRIX"
        }
        
        gameOverLabel.numberOfLines = 0
        gameOverLabel.alpha = 1
        
        playButton.alpha = 1
        instructionsLabel.alpha = 1
        
        clearSnake()
        
        if let foodNode = foodNode {
            foodNode.removeFromParent()
        }
    }
    
    private func spawnFood() {
        var newFood: Position
        repeat {
            newFood = Position(x: Int.random(in: 0..<gridWidth), y: Int.random(in: 0..<gridHeight))
        } while snake.contains { $0.x == newFood.x && $0.y == newFood.y }
        
        food = newFood
    }
    
    private func renderSnake() {
        clearSnake()
        
        for (index, segment) in snake.enumerated() {
            let node = SKShapeNode(rectOf: CGSize(width: CGFloat(gridSize - 2), height: CGFloat(gridSize - 2)))
            
            if index == 0 {
                // Snake head with glow effect
                node.fillColor = ColorPalettes.Snake.snakeHead
                node.strokeColor = ColorPalettes.Snake.snakeHead
                node.lineWidth = 2
                node.glowWidth = 4
            } else {
                // Snake body segments
                let alpha = 1.0 - (Double(index) * 0.05) // Fade towards tail
                node.fillColor = ColorPalettes.Snake.snakeBody.withAlphaComponent(max(0.3, alpha))
                node.strokeColor = ColorPalettes.Snake.snakeBody
                node.lineWidth = 1
                node.glowWidth = 2
            }
            
            node.position = gridToScreen(segment)
            snakeNodes.append(node)
            addChild(node)
        }
    }
    
    private func renderFood() {
        if let foodNode = foodNode {
            foodNode.removeFromParent()
        }
        
        foodNode = SKShapeNode(circleOfRadius: CGFloat(gridSize / 2 - 1))
        foodNode.fillColor = ColorPalettes.Snake.food
        foodNode.strokeColor = ColorPalettes.Snake.foodGlow
        foodNode.lineWidth = 2
        foodNode.glowWidth = 8
        foodNode.position = gridToScreen(food)
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        foodNode.run(SKAction.repeatForever(pulseAction))
        
        addChild(foodNode)
    }
    
    private func clearSnake() {
        for node in snakeNodes {
            node.removeFromParent()
        }
        snakeNodes.removeAll()
    }
    
    private func gridToScreen(_ position: Position) -> CGPoint {
        let boardOrigin = CGPoint(
            x: frame.midX - CGFloat(gridWidth * gridSize) / 2,
            y: frame.midY - 50 - CGFloat(gridHeight * gridSize) / 2
        )
        
        return CGPoint(
            x: boardOrigin.x + CGFloat(position.x * gridSize) + CGFloat(gridSize / 2),
            y: boardOrigin.y + CGFloat(position.y * gridSize) + CGFloat(gridSize / 2)
        )
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard gameRunning else { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        
        if deltaTime >= gameSpeed {
            updateGame()
            lastUpdateTime = currentTime
        }
    }
    
    private func updateGame() {
        direction = nextDirection
        
        let head = snake[0]
        let newHead = Position(x: head.x + direction.x, y: head.y + direction.y)
        
        if newHead.x < 0 || newHead.x >= gridWidth || newHead.y < 0 || newHead.y >= gridHeight {
            endGame()
            return
        }
        
        if snake.contains(where: { $0.x == newHead.x && $0.y == newHead.y }) {
            endGame()
            return
        }
        
        snake.insert(newHead, at: 0)
        
        if newHead.x == food.x && newHead.y == food.y {
            score += 10
            scoreLabel.text = "SCORE: \(score)"
            
            // Create score popup effect
            let scorePopup = SKLabelNode(fontNamed: "Helvetica-Bold")
            scorePopup.text = "+10"
            scorePopup.fontSize = 18
            scorePopup.fontColor = ColorPalettes.Snake.snakeHead
            scorePopup.position = gridToScreen(food)
            scorePopup.zPosition = 20
            addChild(scorePopup)
            
            let popupAction = SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.5, duration: 0.3),
                    SKAction.moveBy(x: 0, y: 30, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3)
                ]),
                SKAction.removeFromParent()
            ])
            scorePopup.run(popupAction)
            
            gameSpeed = max(0.05, gameSpeed - 0.005)
            
            spawnFood()
            renderFood()
            
            // Experience for eating food
            UserManager.shared.addExperience(5)
            
            if score % 50 == 0 {
                let bonusLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
                bonusLabel.text = "⚡ SYSTEM ACCELERATION! ⚡"
                bonusLabel.fontSize = 18
                bonusLabel.fontColor = ColorPalettes.Snake.snakeHead
                bonusLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
                addChild(bonusLabel)
                
                let fadeOut = SKAction.sequence([
                    SKAction.wait(forDuration: 1.0),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.removeFromParent()
                ])
                bonusLabel.run(fadeOut)
            }
        } else {
            snake.removeLast()
        }
        
        renderSnake()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = nodes(at: location).first
        
        guard let nodeName = touchedNode?.name else {
            if !gameRunning && playButton.alpha > 0 {
                setupGame()
                startGame()
            }
            return
        }
        
        if nodeName == "back" {
            let scene = ArcadeMenuScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
            return
        }
        
        if nodeName == "play" {
            setupGame()
            startGame()
            return
        }
        
        if nodeName == "gameMode" {
            toggleGameMode()
            return
        }
    }
    
    deinit {
        guard let view = self.view else { return }
        view.removeGestureRecognizer(swipeGestureUp)
        view.removeGestureRecognizer(swipeGestureDown)
        view.removeGestureRecognizer(swipeGestureLeft)
        view.removeGestureRecognizer(swipeGestureRight)
    }
    
    private func toggleGameMode() {
        gameMode = gameMode == .single ? .turnBased : .single
        gameModeButton.text = gameMode == .single ? "⚡ Solo Matrix" : "👥 Dual Matrix"
        
        if gameMode == .turnBased {
            player1Score = 0
            player2Score = 0
            currentPlayerName = "Player 1"
        }
        
        setupGame()
    }
    
    private func updatePlayButtonText() {
        if gameMode == .turnBased {
            playButton.text = "⚡ \(currentPlayerName.uppercased()) ENTER MATRIX"
        } else {
            playButton.text = "⚡ ENTER THE MATRIX"
        }
    }
    
    private func addHighScoreEffect() {
        // Create matrix rain effect for high score
        for i in 0..<10 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let matrixChar = SKLabelNode(fontNamed: "Helvetica")
                matrixChar.text = ["0", "1", "⚡", "🟢"].randomElement() ?? "0"
                matrixChar.fontSize = 16
                matrixChar.fontColor = ColorPalettes.Snake.snakeHead
                matrixChar.position = CGPoint(
                    x: CGFloat.random(in: 0...self.frame.width),
                    y: self.frame.maxY
                )
                matrixChar.alpha = 0.8
                self.addChild(matrixChar)
                
                let fallAction = SKAction.sequence([
                    SKAction.moveBy(x: 0, y: -self.frame.height - 100, duration: 2.0),
                    SKAction.removeFromParent()
                ])
                matrixChar.run(fallAction)
            }
        }
    }
}