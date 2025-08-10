//
//  HangmanScene.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import SpriteKit

class HangmanScene: SKScene {
    
    private let wordCategories = [
        "Animals": ["elephant", "giraffe", "penguin", "dolphin", "kangaroo", "butterfly", "octopus", "rhinoceros"],
        "Programming": ["swift", "python", "javascript", "algorithm", "database", "function", "variable", "debugging"],
        "Countries": ["australia", "brazil", "canada", "denmark", "egypt", "france", "germany", "iceland"],
        "Foods": ["pizza", "hamburger", "spaghetti", "sandwich", "chocolate", "strawberry", "avocado", "sushi"]
    ]
    
    private var currentCategory = ""
    private var currentWord = ""
    private var guessedWord = ""
    private var wrongGuesses: Set<Character> = []
    private var correctGuesses: Set<Character> = []
    private var maxWrongGuesses = 6
    private var gameOver = false
    private var playerWon = false
    private var hintsUsed = 0
    
    private var titleLabel: SKLabelNode!
    private var categoryLabel: SKLabelNode!
    private var wordDisplayLabel: SKLabelNode!
    private var wrongGuessesLabel: SKLabelNode!
    private var hangmanLabel: SKLabelNode!
    private var statusLabel: SKLabelNode!
    private var backButton: SKLabelNode!
    private var newGameButton: SKLabelNode!
    private var hintButton: SKLabelNode!
    private var difficultyButton: SKLabelNode!
    private var alphabetButtons: [SKLabelNode] = []
    
    override func didMove(to view: SKView) {
        setupUI()
        startNewGame()
    }
    
    private func setupUI() {
        backgroundColor = ColorPalettes.Hangman.background
        
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "🎩 GOTHIC HANGMAN 🎩"
        titleLabel.fontSize = 32
        titleLabel.fontColor = ColorPalettes.Hangman.wordText
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 280)
        addChild(titleLabel)
        
        categoryLabel = SKLabelNode(fontNamed: "Helvetica")
        categoryLabel.text = "Category: "
        categoryLabel.fontSize = 20
        categoryLabel.fontColor = ColorPalettes.Hangman.categoryText
        categoryLabel.position = CGPoint(x: frame.midX, y: frame.midY + 240)
        addChild(categoryLabel)
        
        hangmanLabel = SKLabelNode(fontNamed: "Courier")
        hangmanLabel.text = ""
        hangmanLabel.fontSize = 16
        hangmanLabel.fontColor = ColorPalettes.Hangman.gallows
        hangmanLabel.position = CGPoint(x: frame.midX - 100, y: frame.midY + 120)
        hangmanLabel.numberOfLines = 0
        hangmanLabel.verticalAlignmentMode = .center
        addChild(hangmanLabel)
        
        wordDisplayLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        wordDisplayLabel.text = ""
        wordDisplayLabel.fontSize = 36
        wordDisplayLabel.fontColor = ColorPalettes.Hangman.wordText
        wordDisplayLabel.position = CGPoint(x: frame.midX, y: frame.midY + 80)
        addChild(wordDisplayLabel)
        
        wrongGuessesLabel = SKLabelNode(fontNamed: "Helvetica")
        wrongGuessesLabel.text = "Wrong guesses: "
        wrongGuessesLabel.fontSize = 18
        wrongGuessesLabel.fontColor = ColorPalettes.Hangman.wrongLetter
        wrongGuessesLabel.position = CGPoint(x: frame.midX, y: frame.midY + 40)
        addChild(wrongGuessesLabel)
        
        statusLabel = SKLabelNode(fontNamed: "Helvetica")
        statusLabel.text = ""
        statusLabel.fontSize = 20
        statusLabel.fontColor = ColorPalettes.Hangman.wordText
        statusLabel.position = CGPoint(x: frame.midX, y: frame.midY - 40)
        addChild(statusLabel)
        
        hintButton = SKLabelNode(fontNamed: "Helvetica")
        hintButton.text = "💡 Hint"
        hintButton.fontSize = 18
        hintButton.fontColor = ColorPalettes.Hangman.hint
        hintButton.position = CGPoint(x: frame.midX + 100, y: frame.midY + 160)
        hintButton.name = "hint"
        addChild(hintButton)
        
        setupAlphabetButtons()
        
        backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "← Back to Menu"
        backButton.fontSize = 16
        backButton.fontColor = ColorPalettes.Hangman.categoryText
        backButton.position = CGPoint(x: frame.midX - 100, y: frame.midY - 280)
        backButton.name = "back"
        addChild(backButton)
        
        newGameButton = SKLabelNode(fontNamed: "Helvetica")
        newGameButton.text = "🎮 New Game"
        newGameButton.fontSize = 16
        newGameButton.fontColor = ColorPalettes.Hangman.correctLetter
        newGameButton.position = CGPoint(x: frame.midX + 100, y: frame.midY - 280)
        newGameButton.name = "newGame"
        addChild(newGameButton)
        
        // AI Difficulty button
        difficultyButton = SKLabelNode(fontNamed: "Helvetica")
        updateDifficultyButtonText()
        difficultyButton.fontSize = 12
        difficultyButton.fontColor = ColorPalettes.Hangman.hint
        difficultyButton.position = CGPoint(x: frame.midX, y: frame.midY - 300)
        difficultyButton.name = "difficulty"
        addChild(difficultyButton)
    }
    
    private func setupAlphabetButtons() {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let buttonsPerRow = 6
        let buttonSpacing: CGFloat = 45
        let rowSpacing: CGFloat = 40
        let startY = frame.midY - 80
        
        for (index, letter) in alphabet.enumerated() {
            let row = index / buttonsPerRow
            let col = index % buttonsPerRow
            
            let x = frame.midX - CGFloat(buttonsPerRow - 1) * buttonSpacing / 2 + CGFloat(col) * buttonSpacing
            let y = startY - CGFloat(row) * rowSpacing
            
            let button = SKLabelNode(fontNamed: "Helvetica-Bold")
            button.text = String(letter)
            button.fontSize = 22
            button.fontColor = ColorPalettes.Hangman.availableLetter
            button.position = CGPoint(x: x, y: y)
            button.name = "letter_\(letter)"
            
            let background = SKShapeNode(circleOfRadius: 18)
            background.fillColor = SKColor.darkGray
            background.strokeColor = SKColor.white
            background.lineWidth = 1
            background.position = button.position
            background.name = "bg_\(letter)"
            
            addChild(background)
            addChild(button)
            alphabetButtons.append(button)
        }
    }
    
    private func startNewGame() {
        currentCategory = Array(wordCategories.keys).randomElement() ?? "Animals"
        currentWord = wordCategories[currentCategory]?.randomElement()?.lowercased() ?? "elephant"
        guessedWord = String(repeating: "_", count: currentWord.count)
        wrongGuesses.removeAll()
        correctGuesses.removeAll()
        gameOver = false
        playerWon = false
        hintsUsed = 0
        
        updateDisplay()
        resetAlphabetButtons()
    }
    
    private func resetAlphabetButtons() {
        for button in alphabetButtons {
            button.fontColor = SKColor.white
            if let bgName = button.name?.replacingOccurrences(of: "letter_", with: "bg_"),
               let background = childNode(withName: bgName) as? SKShapeNode {
                background.fillColor = SKColor.darkGray
            }
        }
    }
    
    private func updateDisplay() {
        categoryLabel.text = "Category: \(currentCategory)"
        wordDisplayLabel.text = guessedWord.map { $0 == "_" ? "_" : String($0) }.joined(separator: " ")
        wrongGuessesLabel.text = "Wrong guesses (\(wrongGuesses.count)/\(maxWrongGuesses)): " + wrongGuesses.sorted().map { String($0).uppercased() }.joined(separator: " ")
        updateHangman()
        
        if gameOver {
            if playerWon {
                let stats = HighScoreManager.shared
                let streak = stats.hangmanCurrentStreak
                let bestStreak = stats.hangmanBestStreak
                
                statusLabel.text = "🎆 VICTORY! 🎆\n🔥 Streak: \(streak) | Best: \(bestStreak)"
                statusLabel.fontColor = ColorPalettes.Hangman.correctLetter
                statusLabel.numberOfLines = 0
            } else {
                statusLabel.text = "☠️ HANGED! ☠️\nThe word was: \(currentWord.uppercased())"
                statusLabel.fontColor = ColorPalettes.Hangman.wrongLetter
                statusLabel.numberOfLines = 0
            }
        } else {
            statusLabel.text = ""
            statusLabel.numberOfLines = 1
        }
    }
    
    private func updateHangman() {
        let hangmanStages = [
            "",
            "  ┌─┐\n  │ │\n    │\n    │\n    │\n────┴─",
            "  ┌─┐\n  │ │\n  O │\n    │\n    │\n────┴─",
            "  ┌─┐\n  │ │\n  O │\n  │ │\n    │\n────┴─",
            "  ┌─┐\n  │ │\n  O │\n ╱│ │\n    │\n────┴─",
            "  ┌─┐\n  │ │\n  O │\n ╱│╲│\n    │\n────┴─",
            "  ┌─┐\n  │ │\n  O │\n ╱│╲│\n ╱  │\n────┴─",
            "  ┌─┐\n  │ │\n  O │\n ╱│╲│\n ╱ ╲│\n────┴─"
        ]
        
        let stage = min(wrongGuesses.count, hangmanStages.count - 1)
        hangmanLabel.text = hangmanStages[stage]
    }
    
    private func makeGuess(letter: Character) {
        guard !gameOver else { return }
        
        let lowerLetter = Character(letter.lowercased())
        
        if currentWord.contains(lowerLetter) {
            correctGuesses.insert(lowerLetter)
            
            var newGuessedWord = ""
            for char in currentWord {
                if correctGuesses.contains(char) {
                    newGuessedWord += String(char)
                } else {
                    newGuessedWord += "_"
                }
            }
            guessedWord = newGuessedWord
            
            if !guessedWord.contains("_") {
                gameOver = true
                playerWon = true
                
                // Record the win and achievements
                HighScoreManager.shared.recordHangmanResult(won: true)
                AchievementManager.shared.recordWin(
                    game: "hangman",
                    streak: getCurrentWinStreak(),
                    isAI: false,
                    difficulty: nil
                )
                AchievementManager.shared.checkAchievement("hangman_first_win")
                
                // Check for perfect game (no wrong guesses)
                if wrongGuesses.isEmpty {
                    AchievementManager.shared.checkAchievement("hangman_no_mistakes")
                    UserManager.shared.addExperience(200)
                } else {
                    UserManager.shared.addExperience(100)
                }
                
                updateWinStreak(true)
                addVictoryEffect()
            }
        } else {
            wrongGuesses.insert(lowerLetter)
            
            if wrongGuesses.count >= maxWrongGuesses {
                gameOver = true
                playerWon = false
                
                // Record the loss
                HighScoreManager.shared.recordHangmanResult(won: false)
                updateWinStreak(false)
                UserManager.shared.addExperience(25)
            }
        }
        
        updateButtonState(letter: letter)
        updateDisplay()
    }
    
    private func updateButtonState(letter: Character) {
        let buttonName = "letter_\(letter.uppercased())"
        let bgName = "bg_\(letter.uppercased())"
        
        if let button = childNode(withName: buttonName) as? SKLabelNode,
           let background = childNode(withName: bgName) as? SKShapeNode {
            
            if wrongGuesses.contains(Character(letter.lowercased())) {
                button.fontColor = ColorPalettes.Hangman.wrongLetter
                background.fillColor = ColorPalettes.Hangman.wrongLetter.withAlphaComponent(0.3)
                
                // Add shake effect for wrong guess
                let shake = SKAction.sequence([
                    SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                    SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                    SKAction.moveBy(x: -5, y: 0, duration: 0.05)
                ])
                button.run(shake)
            } else if correctGuesses.contains(Character(letter.lowercased())) {
                button.fontColor = ColorPalettes.Hangman.correctLetter
                background.fillColor = ColorPalettes.Hangman.correctLetter.withAlphaComponent(0.3)
                
                // Add glow effect for correct guess
                ColorPalettes.addGlowEffect(to: button, color: ColorPalettes.Hangman.correctLetter, radius: 5)
            }
        }
    }
    
    private func provideHint() {
        guard !gameOver && hintsUsed < 2 else { return }
        
        let difficulty = AIDifficultyManager.shared.hangmanDifficulty
        let shouldGiveGoodHint = Double.random(in: 0...1) < difficulty.hangmanHintFrequency
        
        let unguessedLetters = Set(currentWord.filter { !correctGuesses.contains($0) && $0 != " " })
        
        if shouldGiveGoodHint, let hintLetter = unguessedLetters.randomElement() {
            hintsUsed += 1
            
            let hints = [
                "Try the letter '\(hintLetter.uppercased())'! 🤖",
                "The AI suggests: '\(hintLetter.uppercased())' 💡",
                "Hint from your AI assistant: '\(hintLetter.uppercased())' ✨"
            ]
            
            statusLabel.text = hints.randomElement() ?? "Try '\(hintLetter.uppercased())'"
            statusLabel.fontColor = ColorPalettes.Hangman.hint
        } else {
            // Give a less helpful hint on higher difficulties
            hintsUsed += 1
            
            let vagueHints = [
                "🤔 Try a common vowel...",
                "💭 Think about the category: \(currentCategory)",
                "🎯 Consider the word length...",
                "📚 What letters appear frequently in English?"
            ]
            
            statusLabel.text = vagueHints.randomElement() ?? "🤔 Good luck!"
            statusLabel.fontColor = ColorPalettes.Hangman.availableLetter
            
            if hintsUsed >= 2 {
                hintButton.fontColor = ColorPalettes.Hangman.availableLetter.withAlphaComponent(0.5)
                hintButton.text = "🚫 No more hints"
            } else {
                hintButton.text = "💡 Hint (\(2 - hintsUsed) left)"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !self.gameOver {
                    self.statusLabel.text = ""
                }
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
        
        if nodeName == "newGame" {
            startNewGame()
            return
        }
        
        if nodeName == "hint" && hintsUsed < 2 && !gameOver {
            provideHint()
            return
        }
        
        if nodeName == "difficulty" {
            cycleDifficulty()
            return
        }
        
        if nodeName.hasPrefix("letter_") && !gameOver {
            let letterString = nodeName.replacingOccurrences(of: "letter_", with: "")
            if let letter = letterString.first {
                let lowerLetter = Character(letter.lowercased())
                
                if !wrongGuesses.contains(lowerLetter) && !correctGuesses.contains(lowerLetter) {
                    makeGuess(letter: letter)
                }
            }
        }
    }
    
    private func addVictoryEffect() {
        // Create floating letters effect for victory
        let letters = Array(currentWord.uppercased())
        
        for (index, letter) in letters.enumerated() {
            let delay = Double(index) * 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let letterNode = SKLabelNode(fontNamed: "Helvetica-Bold")
                letterNode.text = String(letter)
                letterNode.fontSize = 24
                letterNode.fontColor = ColorPalettes.Hangman.correctLetter
                letterNode.position = CGPoint(
                    x: CGFloat.random(in: 50...self.frame.width - 50),
                    y: self.frame.maxY
                )
                letterNode.alpha = 0.9
                self.addChild(letterNode)
                
                let floatAction = SKAction.sequence([
                    SKAction.group([
                        SKAction.moveBy(x: CGFloat.random(in: -50...50), y: -200, duration: 3.0),
                        SKAction.rotate(byAngle: CGFloat.random(in: -1...1), duration: 3.0),
                        SKAction.fadeOut(withDuration: 3.0)
                    ]),
                    SKAction.removeFromParent()
                ])
                letterNode.run(floatAction)
            }
        }
        
        // Add screen flash effect
        let flashOverlay = SKShapeNode(rectOf: frame.size)
        flashOverlay.fillColor = ColorPalettes.Hangman.correctLetter.withAlphaComponent(0.3)
        flashOverlay.strokeColor = SKColor.clear
        flashOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        flashOverlay.zPosition = 50
        addChild(flashOverlay)
        
        let flashAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        flashOverlay.run(flashAction)
    }
    
    private func updateDifficultyButtonText() {
        let difficulty = AIDifficultyManager.shared.hangmanDifficulty
        difficultyButton.text = "Hints: \(difficulty.rawValue)"
    }
    
    private func cycleDifficulty() {
        let current = AIDifficultyManager.shared.hangmanDifficulty
        let allDifficulties = AIDifficulty.allCases
        
        if let currentIndex = allDifficulties.firstIndex(of: current) {
            let nextIndex = (currentIndex + 1) % allDifficulties.count
            AIDifficultyManager.shared.hangmanDifficulty = allDifficulties[nextIndex]
            updateDifficultyButtonText()
            
            // Show difficulty change message
            statusLabel.text = "🎩 Hint Quality: \(allDifficulties[nextIndex].displayName)"
            statusLabel.fontColor = ColorPalettes.Hangman.hint
            
            // Clear message after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.statusLabel.text?.contains("Hint Quality") == true {
                    self.statusLabel.text = ""
                }
            }
        }
    }
    
    private func getCurrentWinStreak() -> Int {
        return UserDefaults.standard.integer(forKey: "HangmanWinStreak")
    }
    
    private func updateWinStreak(_ won: Bool) {
        if won {
            let currentStreak = getCurrentWinStreak() + 1
            UserDefaults.standard.set(currentStreak, forKey: "HangmanWinStreak")
            
            // Check streak achievements
            if currentStreak >= 5 {
                AchievementManager.shared.checkAchievement("hangman_streak")
            }
        } else {
            UserDefaults.standard.set(0, forKey: "HangmanWinStreak")
        }
    }
}