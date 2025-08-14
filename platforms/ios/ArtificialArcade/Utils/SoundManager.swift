//
//  SoundManager.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation
import AVFoundation

enum SoundEffect: String, CaseIterable {
    case move = "move"
    case win = "win"
    case lose = "lose" 
    case draw = "draw"
    case error = "error"
    case buttonTap = "button_tap"
    case achievement = "achievement"
    case gameStart = "game_start"
    case gameEnd = "game_end"
    case menuMusic = "menu_music"
    case gameMusic = "game_music"
    
    var fileName: String {
        return self.rawValue
    }
    
    var fileExtension: String {
        switch self {
        case .menuMusic, .gameMusic:
            return "mp3"
        default:
            return "wav"
        }
    }
    
    var isMusic: Bool {
        return self == .menuMusic || self == .gameMusic
    }
}

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var effectsVolume: Float = 0.7
    private var musicVolume: Float = 0.4
    private var isSoundEnabled: Bool = true
    private var isMusicEnabled: Bool = true
    
    private init() {
        setupAudioSession()
        loadSounds()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadSounds() {
        for effect in SoundEffect.allCases {
            loadSound(effect)
        }
    }
    
    private func loadSound(_ effect: SoundEffect) {
        guard let url = Bundle.main.url(forResource: effect.fileName, withExtension: effect.fileExtension) else {
            print("Sound file not found: \(effect.fileName).\(effect.fileExtension)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = effect.isMusic ? musicVolume : effectsVolume
            audioPlayers[effect.rawValue] = player
        } catch {
            print("Error loading sound \(effect.fileName): \(error)")
        }
    }
    
    func playEffect(_ effect: SoundEffect) {
        guard isSoundEnabled, !effect.isMusic else { return }
        
        guard let player = audioPlayers[effect.rawValue] else {
            print("Sound player not found for: \(effect.rawValue)")
            return
        }
        
        player.stop()
        player.currentTime = 0
        player.play()
    }
    
    func playMusic(_ music: SoundEffect, loop: Bool = true) {
        guard isMusicEnabled, music.isMusic else { return }
        
        // Stop current music if playing
        stopMusic()
        
        guard let player = audioPlayers[music.rawValue] else {
            print("Music player not found for: \(music.rawValue)")
            return
        }
        
        musicPlayer = player
        musicPlayer?.numberOfLoops = loop ? -1 : 0
        musicPlayer?.play()
    }
    
    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }
    
    func pauseMusic() {
        musicPlayer?.pause()
    }
    
    func resumeMusic() {
        musicPlayer?.play()
    }
    
    // MARK: - Volume Controls
    func setEffectsVolume(_ volume: Float) {
        effectsVolume = max(0.0, min(1.0, volume))
        
        for (key, player) in audioPlayers {
            if let effect = SoundEffect(rawValue: key), !effect.isMusic {
                player.volume = effectsVolume
            }
        }
        
        UserDefaults.standard.set(effectsVolume, forKey: "SoundEffectsVolume")
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0.0, min(1.0, volume))
        musicPlayer?.volume = musicVolume
        
        for (key, player) in audioPlayers {
            if let effect = SoundEffect(rawValue: key), effect.isMusic {
                player.volume = musicVolume
            }
        }
        
        UserDefaults.standard.set(musicVolume, forKey: "MusicVolume")
    }
    
    func getEffectsVolume() -> Float {
        return effectsVolume
    }
    
    func getMusicVolume() -> Float {
        return musicVolume
    }
    
    // MARK: - Enable/Disable Controls
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        if !enabled {
            stopAllSounds()
        }
        UserDefaults.standard.set(enabled, forKey: "SoundEnabled")
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        if !enabled {
            stopMusic()
        }
        UserDefaults.standard.set(enabled, forKey: "MusicEnabled")
    }
    
    func isSoundEffectsEnabled() -> Bool {
        return isSoundEnabled
    }
    
    func isMusicEffectsEnabled() -> Bool {
        return isMusicEnabled
    }
    
    private func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
        stopMusic()
    }
    
    // MARK: - Settings Persistence
    func loadSettings() {
        effectsVolume = UserDefaults.standard.object(forKey: "SoundEffectsVolume") as? Float ?? 0.7
        musicVolume = UserDefaults.standard.object(forKey: "MusicVolume") as? Float ?? 0.4
        isSoundEnabled = UserDefaults.standard.object(forKey: "SoundEnabled") as? Bool ?? true
        isMusicEnabled = UserDefaults.standard.object(forKey: "MusicEnabled") as? Bool ?? true
        
        // Apply loaded settings
        setEffectsVolume(effectsVolume)
        setMusicVolume(musicVolume)
    }
    
    func resetSettings() {
        setEffectsVolume(0.7)
        setMusicVolume(0.4)
        setSoundEnabled(true)
        setMusicEnabled(true)
    }
}

// MARK: - Game-Specific Sound Extensions
extension SoundManager {
    func playGameStartSound() {
        playEffect(.gameStart)
    }
    
    func playGameEndSound(won: Bool) {
        if won {
            playEffect(.win)
        } else {
            playEffect(.lose)
        }
    }
    
    func playMoveSound(for gameType: GameType) {
        switch gameType {
        case .ticTacToe:
            playEffect(.move)
        case .connectFour:
            playEffect(.move)
        case .snake:
            playEffect(.move)
        case .hangman:
            playEffect(.buttonTap)
        }
    }
    
    func playTicTacToeMove() {
        playEffect(.move)
    }
    
    func playConnectFourDrop() {
        playEffect(.move)
    }
    
    func playSnakeEat() {
        playEffect(.move)
    }
    
    func playHangmanGuess(correct: Bool) {
        if correct {
            playEffect(.move)
        } else {
            playEffect(.error)
        }
    }
    
    func playButtonPress() {
        playEffect(.buttonTap)
    }
    
    func playAchievementUnlocked() {
        playEffect(.achievement)
    }
    
    func playMenuMusic() {
        playMusic(.menuMusic, loop: true)
    }
    
    func playGameMusic() {
        playMusic(.gameMusic, loop: true)
    }
}

// MARK: - Fallback Sound Generation
extension SoundManager {
    private func generateFallbackSounds() {
        // Generate simple tones for missing sound files
        generateTone(frequency: 800, duration: 0.1, for: .move)
        generateTone(frequency: 1200, duration: 0.3, for: .win)
        generateTone(frequency: 400, duration: 0.3, for: .lose)
        generateTone(frequency: 600, duration: 0.2, for: .draw)
        generateTone(frequency: 300, duration: 0.1, for: .error)
        generateTone(frequency: 1000, duration: 0.05, for: .buttonTap)
        generateTone(frequency: 1500, duration: 0.4, for: .achievement)
        generateTone(frequency: 500, duration: 0.2, for: .gameStart)
        generateTone(frequency: 700, duration: 0.2, for: .gameEnd)
    }
    
    private func generateTone(frequency: Double, duration: Double, for effect: SoundEffect) {
        let sampleRate = 44100.0
        let samples = Int(sampleRate * duration)
        var audioData = [Float](repeating: 0.0, count: samples)
        
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            audioData[i] = Float(sin(2.0 * Double.pi * frequency * time) * 0.5)
        }
        
        // Create audio player from generated data
        // Note: This is a simplified implementation
        // In a real app, you'd want to create actual audio files or use Core Audio
    }
}

// MARK: - Audio Settings Protocol
protocol AudioSettingsDelegate: AnyObject {
    func audioSettingsDidChange()
}

extension SoundManager {
    weak var settingsDelegate: AudioSettingsDelegate?
    
    private func notifySettingsChanged() {
        settingsDelegate?.audioSettingsDidChange()
    }
}