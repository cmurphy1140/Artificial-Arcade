//
//  ArcadeMenuScene.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import SpriteKit

class ArcadeMenuScene: SKScene {
    
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!
    private var ticTacToeButton: SKLabelNode!
    private var hangmanButton: SKLabelNode!
    private var snakeButton: SKLabelNode!
    private var connectFourButton: SKLabelNode!
    private var statsButton: SKLabelNode!
    private var profileButton: SKLabelNode!
    private var backgroundGradient: SKSpriteNode!
    
    // Managers
    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    
    override func didMove(to view: SKView) {
        // Initialize user system if not already done
        UserManager.shared.initializeUserSystem()
        
        // Start menu music
        soundManager.playMenuMusic()
        
        setupBackground()
        setupUI()
        addGlowEffects()
        
        // Show any pending achievement notifications
        showPendingAchievements()
    }
    
    private func setupBackground() {
        backgroundColor = ColorPalettes.ArcadeMenu.background
        
        // Create gradient background
        if let gradientTexture = ColorPalettes.createGradientTexture(
            colors: [ColorPalettes.ArcadeMenu.background, ColorPalettes.ArcadeMenu.darkGlow],
            size: frame.size
        ) {
            backgroundGradient = SKSpriteNode(texture: gradientTexture)
            backgroundGradient.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundGradient.zPosition = -1
            addChild(backgroundGradient)
        }
        
        // Add animated particles
        createParticleEffect()
    }
    
    private func setupUI() {
        
        // Title with enhanced styling
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "🎮 ARTIFICIAL ARCADE 🎮"
        titleLabel.fontSize = 36
        titleLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        addChild(titleLabel)
        
        // Subtitle
        subtitleLabel = SKLabelNode(fontNamed: "Helvetica")
        subtitleLabel.text = "FOUR CLASSIC GAMES • AI POWERED • LOCAL MULTIPLAYER"
        subtitleLabel.fontSize = 14
        subtitleLabel.fontColor = ColorPalettes.ArcadeMenu.neonPink
        subtitleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 160)
        addChild(subtitleLabel)
        
        // Game buttons with enhanced styling
        let buttonSpacing: CGFloat = 70
        let startY = frame.midY + 80
        
        ticTacToeButton = createGameButton(
            text: "🎯 TIC-TAC-TOE",
            subtitle: "Strategic • AI Opponent",
            position: CGPoint(x: frame.midX, y: startY),
            color: ColorPalettes.ArcadeMenu.neonCyan,
            backgroundColor: ColorPalettes.ArcadeMenu.buttonBg1
        )
        
        hangmanButton = createGameButton(
            text: "🔤 HANGMAN",
            subtitle: "Word Guessing • Hints Available",
            position: CGPoint(x: frame.midX, y: startY - buttonSpacing),
            color: ColorPalettes.ArcadeMenu.neonPink,
            backgroundColor: ColorPalettes.ArcadeMenu.buttonBg2
        )
        
        snakeButton = createGameButton(
            text: "🐍 SNAKE",
            subtitle: "Classic Arcade • High Score",
            position: CGPoint(x: frame.midX, y: startY - buttonSpacing * 2),
            color: ColorPalettes.ArcadeMenu.neonGreen,
            backgroundColor: ColorPalettes.ArcadeMenu.buttonBg3
        )
        
        connectFourButton = createGameButton(
            text: "🔴 CONNECT FOUR",
            subtitle: "Advanced AI • Drop Strategy",
            position: CGPoint(x: frame.midX, y: startY - buttonSpacing * 3),
            color: ColorPalettes.ArcadeMenu.neonYellow,
            backgroundColor: ColorPalettes.ArcadeMenu.buttonBg4
        )
        
        // High scores button
        statsButton = createStatsButton()
        
        // Profile button
        profileButton = createProfileButton()
        
        addChild(ticTacToeButton)
        addChild(hangmanButton)
        addChild(snakeButton)
        addChild(connectFourButton)
        addChild(statsButton)
        addChild(profileButton)
    }
    
    private func createGameButton(text: String, subtitle: String, position: CGPoint, color: SKColor, backgroundColor: SKColor) -> SKLabelNode {
        // Create background shape
        let backgroundShape = SKShapeNode(rectOf: CGSize(width: 280, height: 50), cornerRadius: 8)
        backgroundShape.fillColor = backgroundColor
        backgroundShape.strokeColor = color
        backgroundShape.lineWidth = 2
        backgroundShape.position = position
        backgroundShape.name = text
        addChild(backgroundShape)
        
        let button = SKLabelNode(fontNamed: "Helvetica-Bold")
        button.text = text
        button.fontSize = 22
        button.fontColor = color
        button.position = position
        button.name = text
        
        // Add subtitle
        let subtitleNode = SKLabelNode(fontNamed: "Helvetica")
        subtitleNode.text = subtitle
        subtitleNode.fontSize = 12
        subtitleNode.fontColor = color.withAlphaComponent(0.7)
        subtitleNode.position = CGPoint(x: 0, y: -20)
        button.addChild(subtitleNode)
        
        return button
    }
    
    private func createStatsButton() -> SKLabelNode {
        let totalGames = HighScoreManager.shared.totalGamesPlayed
        let position = CGPoint(x: frame.midX, y: frame.minY + 100)
        
        // Create background shape
        let backgroundShape = SKShapeNode(rectOf: CGSize(width: 320, height: 35), cornerRadius: 6)
        backgroundShape.fillColor = ColorPalettes.ArcadeMenu.buttonBg1
        backgroundShape.strokeColor = ColorPalettes.ArcadeMenu.accent
        backgroundShape.lineWidth = 1
        backgroundShape.position = position
        backgroundShape.name = "📊 STATS"
        addChild(backgroundShape)
        
        let button = SKLabelNode(fontNamed: "Helvetica")
        button.text = "📊 HIGH SCORES & STATS (\(totalGames) games played)"
        button.fontSize = 14
        button.fontColor = ColorPalettes.ArcadeMenu.accent
        button.position = position
        button.name = "📊 STATS"
        return button
    }
    
    private func createProfileButton() -> SKLabelNode {
        let user = UserManager.shared.currentUser
        let displayName = user?.displayName ?? "Guest"
        let level = user?.playerLevel ?? 1
        let position = CGPoint(x: frame.midX, y: frame.minY + 70)
        
        // Create background shape
        let backgroundShape = SKShapeNode(rectOf: CGSize(width: 300, height: 35), cornerRadius: 6)
        backgroundShape.fillColor = ColorPalettes.ArcadeMenu.buttonBg2
        backgroundShape.strokeColor = ColorPalettes.ArcadeMenu.neonGreen
        backgroundShape.lineWidth = 1
        backgroundShape.position = position
        backgroundShape.name = "👤 PROFILE"
        addChild(backgroundShape)
        
        let button = SKLabelNode(fontNamed: "Helvetica")
        button.text = "👤 PROFILE - \(displayName) (Level \(level))"
        button.fontSize = 14
        button.fontColor = ColorPalettes.ArcadeMenu.neonGreen
        button.position = position
        button.name = "👤 PROFILE"
        return button
    }
    
    private func createParticleEffect() {
        // Create floating particle effect for cyberpunk atmosphere
        for _ in 0..<15 {
            let particle = SKShapeNode(circleOfRadius: 2)
            particle.fillColor = [
                ColorPalettes.ArcadeMenu.neonCyan,
                ColorPalettes.ArcadeMenu.neonPink,
                ColorPalettes.ArcadeMenu.neonGreen
            ].randomElement()?.withAlphaComponent(0.6) ?? ColorPalettes.ArcadeMenu.neonCyan.withAlphaComponent(0.6)
            particle.strokeColor = SKColor.clear
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            particle.zPosition = -0.5
            particle.name = "particle" // Add name for counting
            
            let floatAction = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: 3.0),
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.removeFromParent()
            ])
            
            particle.run(floatAction)
            addChild(particle)
        }
        
        // Schedule ONLY ONE call for the next batch (not per particle!)
        let spawnDelay = SKAction.wait(forDuration: Double.random(in: 3.0...5.0))
        let spawnAction = SKAction.run { [weak self] in
            // Limit total particles on screen to prevent excessive spawning
            let particleCount = self?.children.filter { $0.name == "particle" }.count ?? 0
            if particleCount < 30 {  // Maximum 30 particles on screen
                self?.createParticleEffect()
            } else {
                // Reschedule check when particles are below limit
                self?.run(SKAction.sequence([
                    SKAction.wait(forDuration: 2.0),
                    SKAction.run { self?.createParticleEffect() }
                ]), withKey: "particleRespawn")
            }
        }
        // Use a key to prevent duplicate scheduling
        run(SKAction.sequence([spawnDelay, spawnAction]), withKey: "particleSpawn")
    }
    
    private func addGlowEffects() {
        // Add glow to title
        ColorPalettes.addGlowEffect(to: titleLabel, color: ColorPalettes.ArcadeMenu.neonCyan, radius: 15)
        
        // Add subtle glow to buttons
        ColorPalettes.addGlowEffect(to: ticTacToeButton, color: ColorPalettes.ArcadeMenu.neonCyan, radius: 8)
        ColorPalettes.addGlowEffect(to: hangmanButton, color: ColorPalettes.ArcadeMenu.neonPink, radius: 8)
        ColorPalettes.addGlowEffect(to: snakeButton, color: ColorPalettes.ArcadeMenu.neonGreen, radius: 8)
        ColorPalettes.addGlowEffect(to: connectFourButton, color: ColorPalettes.ArcadeMenu.neonYellow, radius: 8)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = nodes(at: location).first
        
        guard let buttonName = touchedNode?.name else { return }
        
        // Add button press effect and feedback
        addButtonPressEffect(to: touchedNode)
        soundManager.playButtonPress()
        hapticManager.lightImpact()
        
        switch buttonName {
        case "🎯 TIC-TAC-TOE":
            let scene = TicTacToeScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        case "🔤 HANGMAN":
            let scene = HangmanScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        case "🐍 SNAKE":
            let scene = SnakeScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        case "🔴 CONNECT FOUR":
            let scene = ConnectFourScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        case "📊 STATS":
            showStatsPopup()
        case "closeStats":
            closeStatsPopup()
        case "👤 PROFILE":
            let scene = UserProfileScene(size: self.size)
            scene.scaleMode = .aspectFill
            let transition = SKTransition.crossFade(withDuration: 0.5)
            self.view?.presentScene(scene, transition: transition)
        default:
            break
        }
    }
    
    private func addButtonPressEffect(to node: SKNode?) {
        guard let node = node else { return }
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        node.run(SKAction.sequence([scaleDown, scaleUp]))
    }
    
    private func showStatsPopup() {
        let stats = HighScoreManager.shared.getGameSummary()
        
        // Create overlay
        let overlay = SKShapeNode(rectOf: frame.size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.8)
        overlay.strokeColor = SKColor.clear
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 100
        overlay.name = "statsOverlay"
        
        // Create stats panel
        let panel = SKShapeNode(rectOf: CGSize(width: 320, height: 400))
        panel.fillColor = ColorPalettes.ArcadeMenu.darkGlow
        panel.strokeColor = ColorPalettes.ArcadeMenu.neonCyan
        panel.lineWidth = 2
        panel.position = CGPoint(x: frame.midX, y: frame.midY)
        panel.zPosition = 101
        
        // Add stats text
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "🏆 ARCADE STATISTICS"
        titleLabel.fontSize = 18
        titleLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        titleLabel.position = CGPoint(x: 0, y: 150)
        panel.addChild(titleLabel)
        
        let statsText = """
        📊 Total Games Played: \(stats["totalGames"] as? Int ?? 0)
        
        🎯 Tic-Tac-Toe:
           Player Wins: \(stats["ticTacToeWins"] as? Int ?? 0)
           AI Wins: \(stats["ticTacToeAIWins"] as? Int ?? 0)
        
        🔤 Hangman:
           Total Wins: \(stats["hangmanWins"] as? Int ?? 0)
           Best Streak: \(stats["hangmanStreak"] as? Int ?? 0)
        
        🐍 Snake:
           High Score: \(stats["snakeHigh"] as? Int ?? 0)
           Games Played: \(stats["snakeGames"] as? Int ?? 0)
        
        🔴 Connect Four:
           Player Wins: \(stats["connectWins"] as? Int ?? 0)
           AI Wins: \(stats["connectAIWins"] as? Int ?? 0)
        """
        
        let statsLabel = SKLabelNode(fontNamed: "Helvetica")
        statsLabel.text = statsText
        statsLabel.fontSize = 13
        statsLabel.fontColor = ColorPalettes.ArcadeMenu.neonPink
        statsLabel.numberOfLines = 0
        statsLabel.preferredMaxLayoutWidth = 280
        statsLabel.position = CGPoint(x: 0, y: 0)
        panel.addChild(statsLabel)
        
        // Close button
        let closeButton = SKLabelNode(fontNamed: "Helvetica-Bold")
        closeButton.text = "✖ CLOSE"
        closeButton.fontSize = 16
        closeButton.fontColor = ColorPalettes.ArcadeMenu.neonYellow
        closeButton.position = CGPoint(x: 0, y: -160)
        closeButton.name = "closeStats"
        panel.addChild(closeButton)
        
        addChild(overlay)
        addChild(panel)
        
        // Add close action to overlay
        overlay.name = "closeStats"
    }
    
    private func closeStatsPopup() {
        childNode(withName: "statsOverlay")?.removeFromParent()
        children.filter { $0.zPosition >= 100 }.forEach { $0.removeFromParent() }
    }
    
    private func showPendingAchievements() {
        let recentAchievements = AchievementManager.shared.recentlyUnlocked
        
        for (index, achievement) in recentAchievements.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.0) {
                self.showAchievementNotification(achievement)
            }
        }
    }
}