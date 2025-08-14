//
//  UserProfileScene.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/10/25.
//

import SpriteKit

class UserProfileScene: SKScene {
    
    private var titleLabel: SKLabelNode!
    private var userInfoPanel: SKShapeNode!
    private var achievementPanel: SKShapeNode!
    private var statsPanel: SKShapeNode!
    
    private var backButton: SKLabelNode!
    private var logoutButton: SKLabelNode!
    private var difficultyButton: SKLabelNode!
    
    private var scrollOffset: CGFloat = 0
    private var maxScrollOffset: CGFloat = 0
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        loadUserData()
    }
    
    private func setupBackground() {
        backgroundColor = ColorPalettes.ArcadeMenu.background
        
        // Create gradient background
        if let gradientTexture = ColorPalettes.createGradientTexture(
            colors: [ColorPalettes.ArcadeMenu.background, ColorPalettes.ArcadeMenu.darkGlow],
            size: frame.size
        ) {
            let background = SKSpriteNode(texture: gradientTexture)
            background.position = CGPoint(x: frame.midX, y: frame.midY)
            background.zPosition = -1
            addChild(background)
        }
    }
    
    private func setupUI() {
        // Title
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "👤 PLAYER PROFILE"
        titleLabel.fontSize = 32
        titleLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        addChild(titleLabel)
        
        // Back button
        backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "← Back"
        backButton.fontSize = 18
        backButton.fontColor = ColorPalettes.ArcadeMenu.neonYellow
        backButton.position = CGPoint(x: 80, y: frame.maxY - 60)
        backButton.name = "back"
        addChild(backButton)
        
        // Global difficulty button
        difficultyButton = SKLabelNode(fontNamed: "Helvetica")
        updateDifficultyButtonText()
        difficultyButton.fontSize = 14
        difficultyButton.fontColor = ColorPalettes.ArcadeMenu.neonGreen
        difficultyButton.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 40)
        difficultyButton.name = "difficulty"
        addChild(difficultyButton)
        
        // Logout button (only for non-guest users)
        if let user = UserManager.shared.currentUser, !user.isGuest {
            logoutButton = SKLabelNode(fontNamed: "Helvetica")
            logoutButton.text = "🚪 Logout"
            logoutButton.fontSize = 14
            logoutButton.fontColor = ColorPalettes.ArcadeMenu.accent
            logoutButton.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 80)
            logoutButton.name = "logout"
            addChild(logoutButton)
        }
        
        ColorPalettes.addGlowEffect(to: titleLabel, color: ColorPalettes.ArcadeMenu.neonCyan, radius: 8)
    }
    
    private func loadUserData() {
        guard let user = UserManager.shared.currentUser else { return }
        
        let panelWidth: CGFloat = 350
        let panelSpacing: CGFloat = 20
        var currentY = frame.maxY - 120
        
        // User Info Panel
        userInfoPanel = createPanel(
            title: "🎮 USER INFORMATION",
            content: createUserInfoContent(user: user),
            width: panelWidth,
            position: CGPoint(x: frame.midX, y: currentY)
        )
        addChild(userInfoPanel)
        currentY -= userInfoPanel.frame.height + panelSpacing
        
        // Stats Panel
        let stats = HighScoreManager.shared.getGameSummary()
        statsPanel = createPanel(
            title: "📊 GAME STATISTICS",
            content: createStatsContent(stats: stats),
            width: panelWidth,
            position: CGPoint(x: frame.midX, y: currentY)
        )
        addChild(statsPanel)
        currentY -= statsPanel.frame.height + panelSpacing
        
        // Achievement Panel
        let achievements = AchievementManager.shared.getUnlockedAchievements()
        achievementPanel = createPanel(
            title: "🏆 ACHIEVEMENTS (\(achievements.count)/\(AchievementManager.shared.achievements.count))",
            content: createAchievementContent(achievements: achievements),
            width: panelWidth,
            position: CGPoint(x: frame.midX, y: currentY)
        )
        addChild(achievementPanel)
        
        // Calculate max scroll offset
        maxScrollOffset = max(0, abs(currentY - achievementPanel.frame.height/2) - frame.height + 200)
    }
    
    private func createPanel(title: String, content: [SKNode], width: CGFloat, position: CGPoint) -> SKShapeNode {
        let contentHeight = CGFloat(content.count * 25 + 60) // Approximate height
        let panel = SKShapeNode(rectOf: CGSize(width: width, height: contentHeight), cornerRadius: 12)
        panel.fillColor = ColorPalettes.ArcadeMenu.darkGlow.withAlphaComponent(0.9)
        panel.strokeColor = ColorPalettes.ArcadeMenu.neonCyan
        panel.lineWidth = 2
        panel.position = position
        
        // Panel title
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = title
        titleLabel.fontSize = 18
        titleLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        titleLabel.position = CGPoint(x: 0, y: contentHeight/2 - 30)
        panel.addChild(titleLabel)
        
        // Add content
        var yOffset = contentHeight/2 - 60
        for node in content {
            node.position = CGPoint(x: 0, y: yOffset)
            panel.addChild(node)
            yOffset -= 25
        }
        
        return panel
    }
    
    private func createUserInfoContent(user: User) -> [SKNode] {
        var content: [SKNode] = []
        
        // Display name and avatar
        let nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        nameLabel.text = "\(user.avatarEmoji) \(user.displayName)"
        nameLabel.fontSize = 20
        nameLabel.fontColor = ColorPalettes.ArcadeMenu.neonYellow
        content.append(nameLabel)
        
        // Username
        let usernameLabel = SKLabelNode(fontNamed: "Helvetica")
        usernameLabel.text = "@\(user.username)"
        usernameLabel.fontSize = 16
        usernameLabel.fontColor = ColorPalettes.ArcadeMenu.neonGreen
        content.append(usernameLabel)
        
        // Level and experience
        let levelLabel = SKLabelNode(fontNamed: "Helvetica")
        levelLabel.text = "🌟 Level \(user.playerLevel) (\(Int(user.levelProgress * 100))% to next)"
        levelLabel.fontSize = 14
        levelLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        content.append(levelLabel)
        
        // Total playtime
        let hoursPlayed = Int(user.totalPlayTime / 3600)
        let minutesPlayed = Int((user.totalPlayTime.truncatingRemainder(dividingBy: 3600)) / 60)
        let timeLabel = SKLabelNode(fontNamed: "Helvetica")
        timeLabel.text = "⏱️ Total Playtime: \(hoursPlayed)h \(minutesPlayed)m"
        timeLabel.fontSize = 14
        timeLabel.fontColor = ColorPalettes.ArcadeMenu.neonPink
        content.append(timeLabel)
        
        // Member since
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let memberLabel = SKLabelNode(fontNamed: "Helvetica")
        memberLabel.text = "📅 Member since \(formatter.string(from: user.dateCreated))"
        memberLabel.fontSize = 12
        memberLabel.fontColor = ColorPalettes.ArcadeMenu.accent
        content.append(memberLabel)
        
        // Account type
        let typeLabel = SKLabelNode(fontNamed: "Helvetica")
        typeLabel.text = user.isGuest ? "👤 Guest Account" : "🎮 Registered Player"
        typeLabel.fontSize = 12
        typeLabel.fontColor = user.isGuest ? ColorPalettes.ArcadeMenu.accent : ColorPalettes.ArcadeMenu.neonGreen
        content.append(typeLabel)
        
        return content
    }
    
    private func createStatsContent(stats: [String: Any]) -> [SKNode] {
        var content: [SKNode] = []
        
        // Total games
        let totalLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        totalLabel.text = "🎮 Total Games: \(stats["totalGames"] as? Int ?? 0)"
        totalLabel.fontSize = 16
        totalLabel.fontColor = ColorPalettes.ArcadeMenu.neonYellow
        content.append(totalLabel)
        
        // Tic-Tac-Toe stats
        let tttWins = stats["ticTacToeWins"] as? Int ?? 0
        let tttAIWins = stats["ticTacToeAIWins"] as? Int ?? 0
        let tttLabel = SKLabelNode(fontNamed: "Helvetica")
        tttLabel.text = "⚡ Tic-Tac-Toe: \(tttWins)W - \(tttAIWins)L vs AI"
        tttLabel.fontSize = 14
        tttLabel.fontColor = ColorPalettes.TicTacToe.playerX
        content.append(tttLabel)
        
        // Hangman stats
        let hangmanWins = stats["hangmanWins"] as? Int ?? 0
        let hangmanStreak = stats["hangmanStreak"] as? Int ?? 0
        let hangmanLabel = SKLabelNode(fontNamed: "Helvetica")
        hangmanLabel.text = "🎩 Hangman: \(hangmanWins) wins, \(hangmanStreak) best streak"
        hangmanLabel.fontSize = 14
        hangmanLabel.fontColor = ColorPalettes.Hangman.wordText
        content.append(hangmanLabel)
        
        // Snake stats
        let snakeHigh = stats["snakeHigh"] as? Int ?? 0
        let snakeGames = stats["snakeGames"] as? Int ?? 0
        let snakeLabel = SKLabelNode(fontNamed: "Helvetica")
        snakeLabel.text = "🐍 Snake: \(snakeHigh) high score, \(snakeGames) games"
        snakeLabel.fontSize = 14
        snakeLabel.fontColor = ColorPalettes.Snake.snakeHead
        content.append(snakeLabel)
        
        // Connect Four stats
        let c4Wins = stats["connectWins"] as? Int ?? 0
        let c4AIWins = stats["connectAIWins"] as? Int ?? 0
        let c4Label = SKLabelNode(fontNamed: "Helvetica")
        c4Label.text = "🌅 Connect Four: \(c4Wins)W - \(c4AIWins)L vs AI"
        c4Label.fontSize = 14
        c4Label.fontColor = ColorPalettes.ConnectFour.player1
        content.append(c4Label)
        
        return content
    }
    
    private func createAchievementContent(achievements: [Achievement]) -> [SKNode] {
        var content: [SKNode] = []
        
        // Completion percentage
        let completion = AchievementManager.shared.getCompletionPercentage()
        let completionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        completionLabel.text = "🏆 \(Int(completion * 100))% Complete"
        completionLabel.fontSize = 16
        completionLabel.fontColor = ColorPalettes.ArcadeMenu.neonYellow
        content.append(completionLabel)
        
        // Recent achievements (max 5)
        let recentAchievements = Array(achievements.prefix(5))
        for achievement in recentAchievements {
            let achievementLabel = SKLabelNode(fontNamed: "Helvetica")
            achievementLabel.text = "\(achievement.emoji) \(achievement.title)"
            achievementLabel.fontSize = 14
            achievementLabel.fontColor = ColorPalettes.ArcadeMenu.neonGreen
            content.append(achievementLabel)
        }
        
        if achievements.count > 5 {
            let moreLabel = SKLabelNode(fontNamed: "Helvetica")
            moreLabel.text = "... and \(achievements.count - 5) more!"
            moreLabel.fontSize = 12
            moreLabel.fontColor = ColorPalettes.ArcadeMenu.accent
            content.append(moreLabel)
        }
        
        // Experience earned from achievements
        let totalExp = AchievementManager.shared.getTotalExperienceEarned()
        let expLabel = SKLabelNode(fontNamed: "Helvetica")
        expLabel.text = "⭐ \(totalExp) XP from achievements"
        expLabel.fontSize = 12
        expLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        content.append(expLabel)
        
        return content
    }
    
    private func updateDifficultyButtonText() {
        let difficulty = AIDifficultyManager.shared.generalDifficulty
        difficultyButton.text = "🎛️ AI: \(difficulty.rawValue)"
    }
    
    private func cycleDifficulty() {
        let current = AIDifficultyManager.shared.generalDifficulty
        let allDifficulties = AIDifficulty.allCases
        
        if let currentIndex = allDifficulties.firstIndex(of: current) {
            let nextIndex = (currentIndex + 1) % allDifficulties.count
            AIDifficultyManager.shared.generalDifficulty = allDifficulties[nextIndex]
            updateDifficultyButtonText()
            
            // Show confirmation message
            let message = SKLabelNode(fontNamed: "Helvetica")
            message.text = "AI Difficulty set to \(allDifficulties[nextIndex].rawValue) for all games"
            message.fontSize = 14
            message.fontColor = ColorPalettes.ArcadeMenu.neonGreen
            message.position = CGPoint(x: frame.midX, y: frame.midY)
            message.alpha = 0
            addChild(message)
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let wait = SKAction.wait(forDuration: 2.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            
            message.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = nodes(at: location).first
        
        guard let nodeName = touchedNode?.name else { return }
        
        switch nodeName {
        case "back":
            let scene = ArcadeMenuScene(size: self.size)
            scene.scaleMode = .aspectFill
            let transition = SKTransition.crossFade(withDuration: 0.5)
            self.view?.presentScene(scene, transition: transition)
            
        case "logout":
            // Show confirmation
            let confirmLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            confirmLabel.text = "Tap again to logout"
            confirmLabel.fontSize = 16
            confirmLabel.fontColor = ColorPalettes.ArcadeMenu.neonPink
            confirmLabel.position = CGPoint(x: frame.midX, y: frame.midY)
            confirmLabel.name = "confirmLogout"
            addChild(confirmLabel)
            
            // Remove confirmation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                confirmLabel.removeFromParent()
            }
            
        case "confirmLogout":
            UserManager.shared.logout()
            let scene = LoginScene(size: self.size)
            scene.scaleMode = .aspectFill
            let transition = SKTransition.crossFade(withDuration: 1.0)
            self.view?.presentScene(scene, transition: transition)
            
        case "difficulty":
            cycleDifficulty()
            
        default:
            break
        }
    }
}