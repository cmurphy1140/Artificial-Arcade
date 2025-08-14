//
//  AchievementManager.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/10/25.
//

import Foundation

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let experienceReward: Int
    let isSecret: Bool
    var isUnlocked: Bool
    var progress: Int
    let maxProgress: Int
    let dateUnlocked: Date?
    
    init(id: String, title: String, description: String, emoji: String, 
         experienceReward: Int, maxProgress: Int = 1, isSecret: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.emoji = emoji
        self.experienceReward = experienceReward
        self.maxProgress = maxProgress
        self.isSecret = isSecret
        self.isUnlocked = false
        self.progress = 0
        self.dateUnlocked = nil
    }
    
    var progressPercentage: Double {
        guard maxProgress > 0 else { return 0 }
        return Double(progress) / Double(maxProgress)
    }
    
    mutating func addProgress(_ amount: Int = 1) -> Bool {
        guard !isUnlocked else { return false }
        
        progress = min(progress + amount, maxProgress)
        
        if progress >= maxProgress {
            isUnlocked = true
            return true
        }
        return false
    }
}

class AchievementManager {
    static let shared = AchievementManager()
    
    private init() {
        loadAchievements()
    }
    
    private enum Keys {
        static let achievements = "UserAchievements"
    }
    
    @Published var achievements: [String: Achievement] = [:]
    @Published var recentlyUnlocked: [Achievement] = []
    
    private func createDefaultAchievements() -> [String: Achievement] {
        var defaultAchievements: [String: Achievement] = [:]
        
        // First time achievements
        defaultAchievements["first_game"] = Achievement(
            id: "first_game",
            title: "First Steps",
            description: "Play your first game",
            emoji: "👶",
            experienceReward: 50
        )
        
        // Game-specific achievements
        
        // Tic-Tac-Toe
        defaultAchievements["ttt_first_win"] = Achievement(
            id: "ttt_first_win",
            title: "Tic-Tac-Champion",
            description: "Win your first Tic-Tac-Toe game",
            emoji: "⚡",
            experienceReward: 100
        )
        
        defaultAchievements["ttt_perfect_game"] = Achievement(
            id: "ttt_perfect_game",
            title: "Perfect Strategy",
            description: "Win a Tic-Tac-Toe game in 3 moves",
            emoji: "🎯",
            experienceReward: 200
        )
        
        defaultAchievements["ttt_ai_slayer"] = Achievement(
            id: "ttt_ai_slayer",
            title: "AI Slayer",
            description: "Beat the AI 10 times in Tic-Tac-Toe",
            emoji: "🤖",
            experienceReward: 300,
            maxProgress: 10
        )
        
        // Hangman
        defaultAchievements["hangman_first_win"] = Achievement(
            id: "hangman_first_win",
            title: "Word Master",
            description: "Solve your first word in Hangman",
            emoji: "📚",
            experienceReward: 100
        )
        
        defaultAchievements["hangman_no_mistakes"] = Achievement(
            id: "hangman_no_mistakes",
            title: "Perfect Guesser",
            description: "Solve a word without any wrong guesses",
            emoji: "🎯",
            experienceReward: 200
        )
        
        defaultAchievements["hangman_streak"] = Achievement(
            id: "hangman_streak",
            title: "On Fire!",
            description: "Win 5 Hangman games in a row",
            emoji: "🔥",
            experienceReward: 400,
            maxProgress: 5
        )
        
        // Snake
        defaultAchievements["snake_first_score"] = Achievement(
            id: "snake_first_score",
            title: "Digital Serpent",
            description: "Score your first points in Snake",
            emoji: "🐍",
            experienceReward: 100
        )
        
        defaultAchievements["snake_high_score"] = Achievement(
            id: "snake_high_score",
            title: "Matrix Hacker",
            description: "Score 500 points in Snake",
            emoji: "💚",
            experienceReward: 300,
            maxProgress: 500
        )
        
        defaultAchievements["snake_speed_demon"] = Achievement(
            id: "snake_speed_demon",
            title: "Speed Demon",
            description: "Reach maximum speed in Snake",
            emoji: "⚡",
            experienceReward: 250
        )
        
        // Connect Four
        defaultAchievements["c4_first_win"] = Achievement(
            id: "c4_first_win",
            title: "Connect Master",
            description: "Win your first Connect Four game",
            emoji: "🔴",
            experienceReward: 100
        )
        
        defaultAchievements["c4_diagonal_win"] = Achievement(
            id: "c4_diagonal_win",
            title: "Diagonal Domination",
            description: "Win with a diagonal connection",
            emoji: "↗️",
            experienceReward: 150
        )
        
        defaultAchievements["c4_ai_crusher"] = Achievement(
            id: "c4_ai_crusher",
            title: "Sunset Champion",
            description: "Beat the Expert AI in Connect Four",
            emoji: "🌅",
            experienceReward: 500
        )
        
        // Streak achievements
        defaultAchievements["win_streak_5"] = Achievement(
            id: "win_streak_5",
            title: "Hot Streak",
            description: "Win 5 games in a row across any games",
            emoji: "🔥",
            experienceReward: 200,
            maxProgress: 5
        )
        
        defaultAchievements["win_streak_10"] = Achievement(
            id: "win_streak_10",
            title: "Unstoppable",
            description: "Win 10 games in a row across any games",
            emoji: "🚀",
            experienceReward: 500,
            maxProgress: 10
        )
        
        // Time-based achievements
        defaultAchievements["play_time_hour"] = Achievement(
            id: "play_time_hour",
            title: "Dedicated Player",
            description: "Play for a total of 1 hour",
            emoji: "⏰",
            experienceReward: 200,
            maxProgress: 3600 // seconds
        )
        
        defaultAchievements["daily_player"] = Achievement(
            id: "daily_player",
            title: "Daily Devotee",
            description: "Play games for 7 consecutive days",
            emoji: "📅",
            experienceReward: 300,
            maxProgress: 7
        )
        
        // Skill-based achievements
        defaultAchievements["master_all_games"] = Achievement(
            id: "master_all_games",
            title: "Arcade Master",
            description: "Win at least once in every game",
            emoji: "👑",
            experienceReward: 1000,
            maxProgress: 4
        )
        
        // Secret achievements
        defaultAchievements["easter_egg"] = Achievement(
            id: "easter_egg",
            title: "Secret Hunter",
            description: "Found a hidden easter egg",
            emoji: "🥚",
            experienceReward: 250,
            isSecret: true
        )
        
        defaultAchievements["konami_code"] = Achievement(
            id: "konami_code",
            title: "Classic Gamer",
            description: "Entered the Konami code",
            emoji: "🕹️",
            experienceReward: 300,
            isSecret: true
        )
        
        // Level achievements
        defaultAchievements["level_5"] = Achievement(
            id: "level_5",
            title: "Rising Star",
            description: "Reach player level 5",
            emoji: "⭐",
            experienceReward: 100
        )
        
        defaultAchievements["level_10"] = Achievement(
            id: "level_10",
            title: "Arcade Veteran",
            description: "Reach player level 10",
            emoji: "🎖️",
            experienceReward: 200
        )
        
        defaultAchievements["level_20"] = Achievement(
            id: "level_20",
            title: "Gaming Legend",
            description: "Reach player level 20",
            emoji: "🏆",
            experienceReward: 500
        )
        
        return defaultAchievements
    }
    
    private func loadAchievements() {
        guard let data = UserDefaults.standard.data(forKey: Keys.achievements),
              let savedAchievements = try? JSONDecoder().decode([String: Achievement].self, from: data) else {
            // First time - create default achievements
            achievements = createDefaultAchievements()
            saveAchievements()
            return
        }
        
        // Merge with defaults (for new achievements added in updates)
        let defaultAchievements = createDefaultAchievements()
        achievements = savedAchievements
        
        // Add any new achievements
        for (key, defaultAchievement) in defaultAchievements {
            if achievements[key] == nil {
                achievements[key] = defaultAchievement
            }
        }
        
        saveAchievements()
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: Keys.achievements)
        }
    }
    
    func checkAchievement(_ id: String, progress: Int = 1) {
        guard var achievement = achievements[id], !achievement.isUnlocked else { return }
        
        let wasUnlocked = achievement.addProgress(progress)
        achievements[id] = achievement
        
        if wasUnlocked {
            recentlyUnlocked.append(achievement)
            UserManager.shared.addExperience(achievement.experienceReward)
            
            // Remove from recently unlocked after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.recentlyUnlocked.removeAll { $0.id == achievement.id }
            }
        }
        
        saveAchievements()
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.values.filter { $0.isUnlocked }.sorted { $0.dateUnlocked ?? Date() > $1.dateUnlocked ?? Date() }
    }
    
    func getProgressAchievements() -> [Achievement] {
        return achievements.values.filter { !$0.isUnlocked && $0.progress > 0 }.sorted { $0.progressPercentage > $1.progressPercentage }
    }
    
    func getAvailableAchievements() -> [Achievement] {
        return achievements.values.filter { !$0.isUnlocked && !$0.isSecret }.sorted { $0.experienceReward > $1.experienceReward }
    }
    
    func getTotalExperienceEarned() -> Int {
        return achievements.values.filter { $0.isUnlocked }.reduce(0) { $0 + $1.experienceReward }
    }
    
    func getCompletionPercentage() -> Double {
        let total = achievements.count
        let unlocked = achievements.values.filter { $0.isUnlocked }.count
        return Double(unlocked) / Double(total)
    }
    
    // Convenience methods for common achievements
    func recordGamePlayed(game: String) {
        checkAchievement("first_game")
        
        // Check master all games achievement
        let gameAchievements = ["ttt_first_win", "hangman_first_win", "snake_first_score", "c4_first_win"]
        let unlockedGameAchievements = gameAchievements.filter { achievements[$0]?.isUnlocked == true }.count
        if unlockedGameAchievements > 0 {
            checkAchievement("master_all_games", progress: unlockedGameAchievements)
        }
    }
    
    func recordWin(game: String, streak: Int, isAI: Bool, difficulty: AIDifficulty?) {
        // Game-specific first wins
        switch game.lowercased() {
        case "tictactoe": checkAchievement("ttt_first_win")
        case "hangman": checkAchievement("hangman_first_win")
        case "snake": checkAchievement("snake_first_score")
        case "connectfour": checkAchievement("c4_first_win")
        default: break
        }
        
        // Streak achievements
        checkAchievement("win_streak_5", progress: min(streak, 5))
        checkAchievement("win_streak_10", progress: min(streak, 10))
        
        // AI-specific achievements
        if isAI {
            switch game.lowercased() {
            case "tictactoe": checkAchievement("ttt_ai_slayer")
            case "connectfour" where difficulty == .expert: checkAchievement("c4_ai_crusher")
            default: break
            }
        }
    }
    
    func recordPlayTime(_ seconds: TimeInterval) {
        checkAchievement("play_time_hour", progress: Int(seconds))
    }
    
    func recordLevelUp(_ level: Int) {
        if level >= 5 { checkAchievement("level_5") }
        if level >= 10 { checkAchievement("level_10") }
        if level >= 20 { checkAchievement("level_20") }
    }
}