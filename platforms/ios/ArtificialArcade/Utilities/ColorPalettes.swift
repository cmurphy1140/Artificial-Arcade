//
//  ColorPalettes.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import SpriteKit

struct ColorPalettes {
    
    // MARK: - Main Menu - Gruvbox Theme
    struct ArcadeMenu {
        static let background = SKColor(red: 0.157, green: 0.157, blue: 0.157, alpha: 1.0)      // #282828 - dark0
        static let neonCyan = SKColor(red: 0.514, green: 0.647, blue: 0.596, alpha: 1.0)        // #83a598 - blue
        static let neonPink = SKColor(red: 0.831, green: 0.525, blue: 0.608, alpha: 1.0)        // #d3869b - purple
        static let neonGreen = SKColor(red: 0.722, green: 0.733, blue: 0.408, alpha: 1.0)       // #b8bb26 - bright_green
        static let neonYellow = SKColor(red: 0.980, green: 0.741, blue: 0.184, alpha: 1.0)      // #fabd2f - bright_yellow
        static let darkGlow = SKColor(red: 0.196, green: 0.196, blue: 0.196, alpha: 0.8)        // #3c3836 - dark1
        static let accent = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 1.0)          // #ebdbb2 - light1
        
        // Button background colors
        static let buttonBg1 = SKColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 0.9)       // #404040 - darker gray
        static let buttonBg2 = SKColor(red: 0.314, green: 0.275, blue: 0.216, alpha: 0.9)       // #504637 - dark brown
        static let buttonBg3 = SKColor(red: 0.306, green: 0.322, blue: 0.235, alpha: 0.9)       // #4e523c - dark green
        static let buttonBg4 = SKColor(red: 0.357, green: 0.275, blue: 0.216, alpha: 0.9)       // #5b4637 - darker brown
    }
    
    // MARK: - Tic-Tac-Toe - Gruvbox Blue Theme
    struct TicTacToe {
        static let background = SKColor(red: 0.157, green: 0.157, blue: 0.157, alpha: 1.0)       // #282828 - dark0
        static let gridLine = SKColor(red: 0.514, green: 0.647, blue: 0.596, alpha: 1.0)        // #83a598 - blue
        static let playerX = SKColor(red: 0.514, green: 0.647, blue: 0.596, alpha: 1.0)         // #83a598 - blue
        static let playerO = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 1.0)         // #ebdbb2 - light1
        static let cellHighlight = SKColor(red: 0.294, green: 0.353, blue: 0.424, alpha: 0.6)   // #4b5a6c - blue tint
        static let winLine = SKColor(red: 0.980, green: 0.741, blue: 0.184, alpha: 1.0)         // #fabd2f - bright_yellow
        static let text = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 1.0)            // #ebdbb2 - light1
        static let accent = SKColor(red: 0.722, green: 0.733, blue: 0.408, alpha: 1.0)          // #b8bb26 - bright_green
    }
    
    // MARK: - Hangman - Gruvbox Dark Theme  
    struct Hangman {
        static let background = SKColor(red: 0.157, green: 0.157, blue: 0.157, alpha: 1.0)       // #282828 - dark0
        static let gallows = SKColor(red: 0.655, green: 0.478, blue: 0.282, alpha: 1.0)         // #a78148 - neutral_yellow
        static let rope = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 1.0)            // #ebdbb2 - light1
        static let correctLetter = SKColor(red: 0.722, green: 0.733, blue: 0.408, alpha: 1.0)   // #b8bb26 - bright_green
        static let wrongLetter = SKColor(red: 0.984, green: 0.286, blue: 0.204, alpha: 1.0)     // #fb4934 - bright_red
        static let availableLetter = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 1.0) // #ebdbb2 - light1
        static let wordText = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 1.0)        // #ebdbb2 - light1
        static let categoryText = SKColor(red: 0.831, green: 0.525, blue: 0.608, alpha: 1.0)    // #d3869b - purple
        static let hint = SKColor(red: 0.980, green: 0.741, blue: 0.184, alpha: 1.0)            // #fabd2f - bright_yellow
    }
    
    // MARK: - Snake - Gruvbox Green Theme
    struct Snake {
        static let background = SKColor(red: 0.157, green: 0.157, blue: 0.157, alpha: 1.0)       // #282828 - dark0
        static let snakeHead = SKColor(red: 0.722, green: 0.733, blue: 0.408, alpha: 1.0)       // #b8bb26 - bright_green
        static let snakeBody = SKColor(red: 0.596, green: 0.592, blue: 0.102, alpha: 1.0)       // #98971a - green
        static let food = SKColor(red: 0.984, green: 0.286, blue: 0.204, alpha: 1.0)            // #fb4934 - bright_red
        static let foodGlow = SKColor(red: 0.984, green: 0.286, blue: 0.204, alpha: 0.8)        // #fb4934 - bright_red (glow)
        static let gridLine = SKColor(red: 0.235, green: 0.219, blue: 0.212, alpha: 0.3)        // #3c3836 - dark1
        static let score = SKColor(red: 0.980, green: 0.741, blue: 0.184, alpha: 1.0)           // #fabd2f - bright_yellow
        static let gameOver = SKColor(red: 0.984, green: 0.286, blue: 0.204, alpha: 1.0)        // #fb4934 - bright_red
    }
    
    // MARK: - Connect Four - Gruvbox Orange Theme
    struct ConnectFour {
        static let background = SKColor(red: 0.157, green: 0.157, blue: 0.157, alpha: 1.0)       // #282828 - dark0
        static let board = SKColor(red: 0.514, green: 0.647, blue: 0.596, alpha: 1.0)           // #83a598 - blue
        static let boardHighlight = SKColor(red: 0.451, green: 0.624, blue: 0.816, alpha: 1.0)  // #739fd1 - aqua
        static let player1 = SKColor(red: 0.984, green: 0.286, blue: 0.204, alpha: 1.0)         // #fb4934 - bright_red
        static let player2 = SKColor(red: 0.980, green: 0.741, blue: 0.184, alpha: 1.0)         // #fabd2f - bright_yellow
        static let emptyCell = SKColor(red: 0.235, green: 0.219, blue: 0.212, alpha: 1.0)       // #3c3836 - dark1
        static let winGlow = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 0.8)         // #ebdbb2 - light1
        static let columnHover = SKColor(red: 0.514, green: 0.647, blue: 0.596, alpha: 0.5)     // #83a598 - blue (transparent)
        static let text = SKColor(red: 0.922, green: 0.859, blue: 0.698, alpha: 1.0)            // #ebdbb2 - light1
    }
    
    // MARK: - Gradient Helpers
    static func createGradientTexture(colors: [SKColor], size: CGSize) -> SKTexture? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let cgColors = colors.map { $0.cgColor }
            
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: nil) {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: 0, y: size.height),
                    options: []
                )
            }
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - Glow Effects
    static func addGlowEffect(to node: SKNode, color: SKColor, radius: CGFloat = 10) {
        node.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                if let shapeNode = node as? SKShapeNode {
                    shapeNode.glowWidth = radius
                }
            },
            SKAction.wait(forDuration: 0.5),
            SKAction.run {
                if let shapeNode = node as? SKShapeNode {
                    shapeNode.glowWidth = radius * 0.5
                }
            },
            SKAction.wait(forDuration: 0.5)
        ])))
    }
}