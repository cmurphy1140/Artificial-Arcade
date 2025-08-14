//
//  ThemeManager.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation
import UIKit

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {
        loadTheme()
    }
    
    private(set) var currentTheme: AppTheme = .system
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "AppTheme")
        applyTheme()
    }
    
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: "AppTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
        applyTheme()
    }
    
    private func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch currentTheme {
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
    
    var isDarkMode: Bool {
        switch currentTheme {
        case .system:
            return UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            return false
        case .dark:
            return true
        }
    }
    
    func handleTraitCollectionChange() {
        if currentTheme == .system {
            // Theme colors automatically adapt with system theme
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("ThemeDidChange")
}

// MARK: - Theme-Aware Color Extensions
extension ColorPalettes {
    
    // Dynamic colors that adapt to light/dark mode
    struct Dynamic {
        static var primaryText: UIColor {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(ColorPalettes.ArcadeMenu.accent)
                default:
                    return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
                }
            }
        }
        
        static var secondaryText: UIColor {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
                default:
                    return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                }
            }
        }
        
        static var primaryBackground: UIColor {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(ColorPalettes.ArcadeMenu.background)
                default:
                    return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
                }
            }
        }
        
        static var secondaryBackground: UIColor {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(ColorPalettes.ArcadeMenu.darkGlow)
                default:
                    return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                }
            }
        }
    }
}

// MARK: - Theme-aware scene support
protocol ThemeAware: AnyObject {
    func applyTheme()
}

extension ThemeAware {
    func observeThemeChanges() {
        NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyTheme()
        }
    }
    
    func removeThemeObserver() {
        NotificationCenter.default.removeObserver(self, name: .themeDidChange, object: nil)
    }
}

// MARK: - System Theme Detection
extension UITraitCollection {
    var isLightMode: Bool {
        return userInterfaceStyle == .light
    }
    
    var isDarkMode: Bool {
        return userInterfaceStyle == .dark
    }
}