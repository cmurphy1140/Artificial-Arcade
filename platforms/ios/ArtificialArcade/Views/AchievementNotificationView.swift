//
//  AchievementNotificationView.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/10/25.
//

import SpriteKit

class AchievementNotificationView: SKNode {
    
    private var backgroundPanel: SKShapeNode!
    private var achievementLabel: SKLabelNode!
    private var experienceLabel: SKLabelNode!
    private var iconLabel: SKLabelNode!
    
    init(achievement: Achievement) {
        super.init()
        setupNotification(for: achievement)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupNotification(for achievement: Achievement) {
        // Create background panel
        backgroundPanel = SKShapeNode(rectOf: CGSize(width: 320, height: 80), cornerRadius: 12)
        backgroundPanel.fillColor = ColorPalettes.ArcadeMenu.darkGlow
        backgroundPanel.strokeColor = ColorPalettes.ArcadeMenu.neonCyan
        backgroundPanel.lineWidth = 2
        backgroundPanel.glowWidth = 5
        addChild(backgroundPanel)
        
        // Achievement icon
        iconLabel = SKLabelNode(fontNamed: "Helvetica")
        iconLabel.text = achievement.emoji
        iconLabel.fontSize = 32
        iconLabel.position = CGPoint(x: -120, y: 0)
        iconLabel.verticalAlignmentMode = .center
        addChild(iconLabel)
        
        // Achievement title and description
        achievementLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        achievementLabel.text = "🏆 ACHIEVEMENT UNLOCKED!\\n\\(achievement.title)\\n\\(achievement.description)"
        achievementLabel.fontSize = 14
        achievementLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        achievementLabel.numberOfLines = 0
        achievementLabel.preferredMaxLayoutWidth = 180
        achievementLabel.position = CGPoint(x: -10, y: 5)
        achievementLabel.verticalAlignmentMode = .center
        addChild(achievementLabel)
        
        // Experience reward
        experienceLabel = SKLabelNode(fontNamed: "Helvetica")
        experienceLabel.text = "+\\(achievement.experienceReward) XP"
        experienceLabel.fontSize = 16
        experienceLabel.fontColor = ColorPalettes.ArcadeMenu.neonYellow
        experienceLabel.position = CGPoint(x: 100, y: -15)
        experienceLabel.verticalAlignmentMode = .center
        addChild(experienceLabel)
        
        // Add glow effect
        ColorPalettes.addGlowEffect(to: backgroundPanel, color: ColorPalettes.ArcadeMenu.neonCyan, radius: 10)
    }
    
    func show(in scene: SKScene, at position: CGPoint = CGPoint(x: 0, y: 0)) {
        self.position = CGPoint(x: position.x, y: scene.frame.maxY + 50) // Start above screen
        self.alpha = 0
        scene.addChild(self)
        zPosition = 1000 // Ensure it appears above everything
        
        // Animate in
        let slideIn = SKAction.move(to: CGPoint(x: position.x, y: scene.frame.maxY - 60), duration: 0.5)
        slideIn.timingMode = .easeOut
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        let showAnimation = SKAction.group([slideIn, fadeIn])
        
        // Scale effect
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let scaleSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            scaleUp,
            scaleDown
        ])
        
        // Hold then slide out
        let wait = SKAction.wait(forDuration: 3.0)
        let slideOut = SKAction.move(to: CGPoint(x: position.x, y: scene.frame.maxY + 100), duration: 0.5)
        slideOut.timingMode = .easeIn
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let hideAnimation = SKAction.group([slideOut, fadeOut])
        
        let fullSequence = SKAction.sequence([
            showAnimation,
            wait,
            hideAnimation,
            SKAction.removeFromParent()
        ])
        
        run(fullSequence)
        run(scaleSequence)
        
        // Add sparkle effects
        addSparkleEffects()
    }
    
    private func addSparkleEffects() {
        for i in 0..<6 {
            let sparkle = SKShapeNode(circleOfRadius: 2)
            sparkle.fillColor = [
                ColorPalettes.ArcadeMenu.neonCyan,
                ColorPalettes.ArcadeMenu.neonYellow,
                ColorPalettes.ArcadeMenu.neonPink
            ].randomElement() ?? ColorPalettes.ArcadeMenu.neonCyan
            sparkle.strokeColor = SKColor.clear
            sparkle.position = CGPoint(
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -35...35)
            )
            sparkle.alpha = 0
            addChild(sparkle)
            
            let delay = Double(i) * 0.1
            let sparkleAnimation = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.group([
                    SKAction.scale(to: 2.0, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5)
                ]),
                SKAction.removeFromParent()
            ])
            
            sparkle.run(sparkleAnimation)
        }
    }
}

// Extension to easily show achievement notifications from any scene
extension SKScene {
    func showAchievementNotification(_ achievement: Achievement) {
        let notification = AchievementNotificationView(achievement: achievement)
        notification.show(in: self, at: CGPoint(x: frame.midX, y: 0))
    }
}