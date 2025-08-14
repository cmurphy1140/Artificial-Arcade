//
//  UserManager.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/10/25.
//

import Foundation
import CryptoKit

struct User: Codable {
    let id: UUID
    var username: String
    var email: String
    var displayName: String
    var avatarEmoji: String
    let dateCreated: Date
    var lastLogin: Date
    var isGuest: Bool
    
    // Achievement and progress data
    var totalPlayTime: TimeInterval
    var favoriteGame: String?
    var playerLevel: Int
    var experience: Int
    
    init(username: String, email: String, displayName: String, isGuest: Bool = false) {
        self.id = UUID()
        self.username = username
        self.email = email
        self.displayName = displayName
        self.avatarEmoji = ["🎮", "🎯", "🎪", "🎨", "⭐", "🚀", "🌟", "💎", "🔥", "⚡"].randomElement() ?? "🎮"
        self.dateCreated = Date()
        self.lastLogin = Date()
        self.isGuest = isGuest
        self.totalPlayTime = 0
        self.favoriteGame = nil
        self.playerLevel = 1
        self.experience = 0
    }
    
    mutating func gainExperience(_ points: Int) {
        experience += points
        
        // Level up calculation (exponential growth)
        let requiredExp = playerLevel * playerLevel * 100
        if experience >= requiredExp {
            playerLevel += 1
            // Bonus experience for leveling up
            experience += 50
        }
    }
    
    var levelProgress: Double {
        let requiredExp = playerLevel * playerLevel * 100
        let previousLevelExp = (playerLevel - 1) * (playerLevel - 1) * 100
        let currentLevelExp = experience - previousLevelExp
        let neededForLevel = requiredExp - previousLevelExp
        return Double(currentLevelExp) / Double(neededForLevel)
    }
}

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case userExists
    case userNotFound
    case weakPassword
    case invalidEmail
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid username or password"
        case .userExists: return "Username already exists"
        case .userNotFound: return "User not found"
        case .weakPassword: return "Password must be at least 6 characters"
        case .invalidEmail: return "Invalid email address"
        case .networkError: return "Network connection error"
        }
    }
}

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    // Keys for UserDefaults
    private enum Keys {
        static let currentUser = "CurrentUser"
        static let allUsers = "AllUsers"
        static let isLoggedIn = "IsLoggedIn"
        static let rememberMe = "RememberMe"
    }
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private var allUsers: [String: User] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.allUsers),
                  let users = try? JSONDecoder().decode([String: User].self, from: data) else {
                return [:]
            }
            return users
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: Keys.allUsers)
            }
        }
    }
    
    func initializeUserSystem() {
        // Check if user was previously logged in
        if UserDefaults.standard.bool(forKey: Keys.rememberMe) {
            loadCurrentUser()
        }
        
        // Create guest user if no user logged in
        if currentUser == nil {
            createGuestUser()
        }
    }
    
    private func loadCurrentUser() {
        guard let data = UserDefaults.standard.data(forKey: Keys.currentUser),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        currentUser = user
        isLoggedIn = !user.isGuest
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser,
              let data = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(data, forKey: Keys.currentUser)
    }
    
    func createGuestUser() {
        let guestNumber = Int.random(in: 1000...9999)
        currentUser = User(
            username: "Guest\(guestNumber)",
            email: "guest@artificial-arcade.com",
            displayName: "Guest Player",
            isGuest: true
        )
        isLoggedIn = false
        saveCurrentUser()
    }
    
    func register(username: String, email: String, password: String, displayName: String) throws {
        // Validation
        guard isValidEmail(email) else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        guard !username.isEmpty && username.count >= 3 else { throw AuthError.weakPassword }
        
        // Check if user already exists
        if allUsers[username.lowercased()] != nil {
            throw AuthError.userExists
        }
        
        // Create new user
        let newUser = User(username: username, email: email, displayName: displayName)
        
        // Save user data
        var users = allUsers
        users[username.lowercased()] = newUser
        allUsers = users
        
        // Hash and store password (simplified for demo)
        let hashedPassword = hashPassword(password)
        UserDefaults.standard.set(hashedPassword, forKey: "password_\(username.lowercased())")
        
        // Log in the new user
        currentUser = newUser
        isLoggedIn = true
        saveCurrentUser()
        UserDefaults.standard.set(true, forKey: Keys.rememberMe)
    }
    
    func login(username: String, password: String, rememberMe: Bool = true) throws {
        // Get stored user
        guard let user = allUsers[username.lowercased()] else {
            throw AuthError.userNotFound
        }
        
        // Verify password
        let hashedPassword = hashPassword(password)
        let storedPassword = UserDefaults.standard.string(forKey: "password_\(username.lowercased())")
        
        guard hashedPassword == storedPassword else {
            throw AuthError.invalidCredentials
        }
        
        // Update last login
        var updatedUser = user
        updatedUser.lastLogin = Date()
        
        // Update stored user data
        var users = allUsers
        users[username.lowercased()] = updatedUser
        allUsers = users
        
        // Set current user
        currentUser = updatedUser
        isLoggedIn = true
        saveCurrentUser()
        UserDefaults.standard.set(rememberMe, forKey: Keys.rememberMe)
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: Keys.rememberMe)
        createGuestUser()
    }
    
    func updateUser(_ updatedUser: User) {
        currentUser = updatedUser
        saveCurrentUser()
        
        // Update in all users if not guest
        if !updatedUser.isGuest {
            var users = allUsers
            users[updatedUser.username.lowercased()] = updatedUser
            allUsers = users
        }
    }
    
    func addPlayTime(_ time: TimeInterval) {
        guard var user = currentUser else { return }
        user.totalPlayTime += time
        updateUser(user)
    }
    
    func addExperience(_ points: Int) {
        guard var user = currentUser else { return }
        user.gainExperience(points)
        updateUser(user)
    }
    
    func updateFavoriteGame(_ game: String) {
        guard var user = currentUser else { return }
        user.favoriteGame = game
        updateUser(user)
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    func getAllUsernames() -> [String] {
        return Array(allUsers.keys)
    }
    
    func deleteAccount(username: String, password: String) throws {
        // Verify credentials first
        try login(username: username, password: password, rememberMe: false)
        
        // Remove user data
        var users = allUsers
        users.removeValue(forKey: username.lowercased())
        allUsers = users
        
        // Remove password
        UserDefaults.standard.removeObject(forKey: "password_\(username.lowercased())")
        
        // Logout and create guest
        logout()
    }
}