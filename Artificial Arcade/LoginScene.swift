//
//  LoginScene.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/10/25.
//

import SpriteKit
import UIKit

class LoginScene: SKScene {
    
    private var titleLabel: SKLabelNode!
    private var usernameField: UITextField!
    private var passwordField: UITextField!
    private var emailField: UITextField!
    private var displayNameField: UITextField!
    
    private var loginButton: SKLabelNode!
    private var registerButton: SKLabelNode!
    private var guestButton: SKLabelNode!
    private var toggleButton: SKLabelNode!
    
    private var statusLabel: SKLabelNode!
    private var rememberMeButton: SKLabelNode!
    
    private var isRegisterMode = false
    private var rememberMe = true
    
    private var backgroundGradient: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        setupTextFields()
        addAnimations()
    }
    
    private func setupBackground() {
        backgroundColor = ColorPalettes.ArcadeMenu.background
        
        // Create animated background
        if let gradientTexture = ColorPalettes.createGradientTexture(
            colors: [
                ColorPalettes.ArcadeMenu.background,
                ColorPalettes.ArcadeMenu.darkGlow,
                ColorPalettes.ArcadeMenu.background
            ],
            size: frame.size
        ) {
            backgroundGradient = SKSpriteNode(texture: gradientTexture)
            backgroundGradient.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundGradient.zPosition = -2
            addChild(backgroundGradient)
        }
        
        // Add floating particles
        createParticleEffect()
    }
    
    private func setupUI() {
        // Title
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        updateTitleForMode()
        titleLabel.fontSize = 36
        titleLabel.fontColor = ColorPalettes.ArcadeMenu.neonCyan
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        addChild(titleLabel)
        
        // Status label for messages
        statusLabel = SKLabelNode(fontNamed: "Helvetica")
        statusLabel.text = ""
        statusLabel.fontSize = 16
        statusLabel.fontColor = ColorPalettes.ArcadeMenu.neonPink
        statusLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        statusLabel.numberOfLines = 0
        addChild(statusLabel)
        
        // Login button
        loginButton = createStyledButton(
            text: isRegisterMode ? "🚀 CREATE ACCOUNT" : "⚡ LOGIN",
            position: CGPoint(x: frame.midX, y: frame.midY - 100),
            color: ColorPalettes.ArcadeMenu.neonCyan
        )
        loginButton.name = "login"
        addChild(loginButton)
        
        // Toggle button (Login/Register)
        toggleButton = createStyledButton(
            text: isRegisterMode ? "Already have an account? Login" : "New player? Create Account",
            position: CGPoint(x: frame.midX, y: frame.midY - 150),
            color: ColorPalettes.ArcadeMenu.neonYellow
        )
        toggleButton.fontSize = 14
        toggleButton.name = "toggle"
        addChild(toggleButton)
        
        // Guest button
        guestButton = createStyledButton(
            text: "👤 CONTINUE AS GUEST",
            position: CGPoint(x: frame.midX, y: frame.midY - 200),
            color: ColorPalettes.ArcadeMenu.accent
        )
        guestButton.fontSize = 16
        guestButton.name = "guest"
        addChild(guestButton)
        
        // Remember me button
        rememberMeButton = SKLabelNode(fontNamed: "Helvetica")
        rememberMeButton.text = rememberMe ? "☑️ Remember Me" : "☐ Remember Me"
        rememberMeButton.fontSize = 14
        rememberMeButton.fontColor = ColorPalettes.ArcadeMenu.neonGreen
        rememberMeButton.position = CGPoint(x: frame.midX, y: frame.midY - 75)
        rememberMeButton.name = "remember"
        addChild(rememberMeButton)
        
        addGlowEffects()
    }
    
    private func setupTextFields() {
        guard let view = self.view else { return }
        
        let fieldWidth: CGFloat = 280
        let fieldHeight: CGFloat = 40
        let centerX = view.bounds.midX - fieldWidth / 2
        
        // Username field
        usernameField = createTextField(
            placeholder: "Username",
            frame: CGRect(x: centerX, y: view.bounds.midY + 50, width: fieldWidth, height: fieldHeight)
        )
        view.addSubview(usernameField)
        
        // Password field
        passwordField = createTextField(
            placeholder: "Password",
            frame: CGRect(x: centerX, y: view.bounds.midY + 5, width: fieldWidth, height: fieldHeight),
            isSecure: true
        )
        view.addSubview(passwordField)
        
        // Email field (for registration)
        emailField = createTextField(
            placeholder: "Email",
            frame: CGRect(x: centerX, y: view.bounds.midY + 95, width: fieldWidth, height: fieldHeight)
        )
        emailField.keyboardType = .emailAddress
        emailField.isHidden = true
        view.addSubview(emailField)
        
        // Display name field (for registration)
        displayNameField = createTextField(
            placeholder: "Display Name",
            frame: CGRect(x: centerX, y: view.bounds.midY + 140, width: fieldWidth, height: fieldHeight)
        )
        displayNameField.isHidden = true
        view.addSubview(displayNameField)
    }
    
    private func createTextField(placeholder: String, frame: CGRect, isSecure: Bool = false) -> UITextField {
        let textField = UITextField(frame: frame)
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.gray]
        )
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = ColorPalettes.ArcadeMenu.neonCyan.cgColor
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        // Add glow effect
        textField.layer.shadowColor = ColorPalettes.ArcadeMenu.neonCyan.cgColor
        textField.layer.shadowRadius = 5
        textField.layer.shadowOpacity = 0.3
        textField.layer.shadowOffset = .zero
        
        return textField
    }
    
    private func createStyledButton(text: String, position: CGPoint, color: SKColor) -> SKLabelNode {
        let button = SKLabelNode(fontNamed: "Helvetica-Bold")
        button.text = text
        button.fontSize = 18
        button.fontColor = color
        button.position = position
        return button
    }
    
    private func updateTitleForMode() {
        titleLabel.text = isRegisterMode ? "🎮 JOIN THE ARCADE 🎮" : "⚡ ARTIFICIAL ARCADE ⚡"
    }
    
    private func toggleMode() {
        isRegisterMode.toggle()
        
        // Animate the transition
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        
        titleLabel.run(SKAction.sequence([
            fadeOut,
            SKAction.run { self.updateTitleForMode() },
            fadeIn
        ]))
        
        loginButton.run(SKAction.sequence([
            fadeOut,
            SKAction.run { 
                self.loginButton.text = self.isRegisterMode ? "🚀 CREATE ACCOUNT" : "⚡ LOGIN"
            },
            fadeIn
        ]))
        
        toggleButton.run(SKAction.sequence([
            fadeOut,
            SKAction.run { 
                self.toggleButton.text = self.isRegisterMode ? "Already have an account? Login" : "New player? Create Account"
            },
            fadeIn
        ]))
        
        // Show/hide additional fields for registration
        UIView.animate(withDuration: 0.3) {
            self.emailField.isHidden = !self.isRegisterMode
            self.displayNameField.isHidden = !self.isRegisterMode
            
            if self.isRegisterMode {
                self.emailField.alpha = 1.0
                self.displayNameField.alpha = 1.0
            } else {
                self.emailField.alpha = 0.0
                self.displayNameField.alpha = 0.0
            }
        }
    }
    
    private func handleLogin() {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showMessage("Please fill in all fields", color: ColorPalettes.ArcadeMenu.neonPink)
            return
        }
        
        if isRegisterMode {
            // Registration
            guard let email = emailField.text, !email.isEmpty,
                  let displayName = displayNameField.text, !displayName.isEmpty else {
                showMessage("Please fill in all fields", color: ColorPalettes.ArcadeMenu.neonPink)
                return
            }
            
            do {
                try UserManager.shared.register(
                    username: username,
                    email: email,
                    password: password,
                    displayName: displayName
                )
                
                showMessage("Account created successfully! Welcome to the Arcade! 🎮", color: ColorPalettes.ArcadeMenu.neonGreen)
                
                // Add registration achievement
                AchievementManager.shared.checkAchievement("first_game")
                
                // Transition to main menu after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.transitionToMainMenu()
                }
                
            } catch {
                showMessage(error.localizedDescription, color: ColorPalettes.ArcadeMenu.neonPink)
            }
        } else {
            // Login
            do {
                try UserManager.shared.login(username: username, password: password, rememberMe: rememberMe)
                showMessage("Welcome back, \\(username)! 🎮", color: ColorPalettes.ArcadeMenu.neonGreen)
                
                // Transition to main menu after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.transitionToMainMenu()
                }
                
            } catch {
                showMessage(error.localizedDescription, color: ColorPalettes.ArcadeMenu.neonPink)
            }
        }
    }
    
    private func handleGuest() {
        UserManager.shared.createGuestUser()
        showMessage("Welcome, Guest Player! 👤", color: ColorPalettes.ArcadeMenu.neonCyan)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.transitionToMainMenu()
        }
    }
    
    private func toggleRememberMe() {
        rememberMe.toggle()
        rememberMeButton.text = rememberMe ? "☑️ Remember Me" : "☐ Remember Me"
        
        // Add feedback animation
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        rememberMeButton.run(scale)
    }
    
    private func showMessage(_ message: String, color: SKColor) {
        statusLabel.text = message
        statusLabel.fontColor = color
        
        // Animate message appearance
        statusLabel.alpha = 0
        statusLabel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(withDuration: 0.5)
        ]))
    }
    
    private func transitionToMainMenu() {
        // Remove text fields
        usernameField.removeFromSuperview()
        passwordField.removeFromSuperview()
        emailField.removeFromSuperview()
        displayNameField.removeFromSuperview()
        
        // Transition to main menu
        let scene = ArcadeMenuScene(size: self.size)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    private func createParticleEffect() {
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 1.5)
            particle.fillColor = [
                ColorPalettes.ArcadeMenu.neonCyan,
                ColorPalettes.ArcadeMenu.neonPink,
                ColorPalettes.ArcadeMenu.neonYellow
            ].randomElement()?.withAlphaComponent(0.4) ?? ColorPalettes.ArcadeMenu.neonCyan.withAlphaComponent(0.4)
            particle.strokeColor = SKColor.clear
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            particle.zPosition = -1
            particle.name = "particle" // Add name for counting
            
            let floatAction = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -20...20), duration: 4.0),
                SKAction.removeFromParent()
            ])
            
            particle.run(floatAction)
            addChild(particle)
        }
        
        // Schedule next particle burst - FIXED: Only one scheduling, not exponential
        let delay = SKAction.wait(forDuration: Double.random(in: 3.0...6.0))
        let spawn = SKAction.run { [weak self] in
            // Limit total particles on screen
            let particleCount = self?.children.filter { $0.name == "particle" }.count ?? 0
            if particleCount < 20 {  // Maximum 20 particles for login scene
                self?.createParticleEffect()
            } else {
                // Reschedule when count drops
                self?.run(SKAction.sequence([
                    SKAction.wait(forDuration: 2.0),
                    SKAction.run { self?.createParticleEffect() }
                ]), withKey: "particleRespawn")
            }
        }
        // Use a key to prevent duplicate scheduling
        run(SKAction.sequence([delay, spawn]), withKey: "particleSpawn")
    }
    
    private func addGlowEffects() {
        ColorPalettes.addGlowEffect(to: titleLabel, color: ColorPalettes.ArcadeMenu.neonCyan, radius: 10)
        ColorPalettes.addGlowEffect(to: loginButton, color: ColorPalettes.ArcadeMenu.neonCyan, radius: 5)
        ColorPalettes.addGlowEffect(to: guestButton, color: ColorPalettes.ArcadeMenu.accent, radius: 5)
    }
    
    private func addAnimations() {
        // Title pulsing animation
        let titlePulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        titleLabel.run(SKAction.repeatForever(titlePulse))
        
        // Stagger in animations for UI elements
        let elements = [loginButton, toggleButton, guestButton, rememberMeButton]
        for (index, element) in elements.enumerated() {
            element?.alpha = 0
            let delay = Double(index) * 0.2
            element?.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.fadeIn(withDuration: 0.5)
            ]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = nodes(at: location).first
        
        guard let nodeName = touchedNode?.name else {
            // Dismiss keyboard if tapping outside fields
            view?.endEditing(true)
            return
        }
        
        // Add touch feedback
        if let node = touchedNode {
            let scale = SKAction.sequence([
                SKAction.scale(to: 0.95, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            node.run(scale)
        }
        
        switch nodeName {
        case "login":
            handleLogin()
        case "toggle":
            toggleMode()
        case "guest":
            handleGuest()
        case "remember":
            toggleRememberMe()
        default:
            break
        }
    }
    
    deinit {
        // Clean up text fields
        usernameField?.removeFromSuperview()
        passwordField?.removeFromSuperview()
        emailField?.removeFromSuperview()
        displayNameField?.removeFromSuperview()
    }
}