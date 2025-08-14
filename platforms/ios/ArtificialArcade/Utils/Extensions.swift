//
//  Extensions.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import Foundation
import SpriteKit
import UIKit

// MARK: - SKNode Extensions
extension SKNode {
    func shake(duration: TimeInterval = 0.1, amplitude: CGFloat = 5) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: amplitude, y: 0, duration: duration/4),
            SKAction.moveBy(x: -amplitude*2, y: 0, duration: duration/2),
            SKAction.moveBy(x: amplitude, y: 0, duration: duration/4)
        ])
        self.run(shake)
    }
    
    func pulse(scale: CGFloat = 1.2, duration: TimeInterval = 0.3) {
        let pulse = SKAction.sequence([
            SKAction.scale(to: scale, duration: duration/2),
            SKAction.scale(to: 1.0, duration: duration/2)
        ])
        self.run(pulse)
    }
    
    func fadeInWithScale(duration: TimeInterval = 0.3) {
        self.alpha = 0
        self.setScale(0.1)
        
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        let scaleUp = SKAction.scale(to: 1.0, duration: duration)
        let group = SKAction.group([fadeIn, scaleUp])
        
        self.run(group)
    }
    
    func bounceIn(duration: TimeInterval = 0.4) {
        self.setScale(0)
        
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: duration * 0.6),
            SKAction.scale(to: 0.9, duration: duration * 0.2),
            SKAction.scale(to: 1.0, duration: duration * 0.2)
        ])
        
        self.run(bounce)
    }
    
    func slideIn(from direction: SlideDirection, distance: CGFloat = 300, duration: TimeInterval = 0.5) {
        let originalPosition = self.position
        
        switch direction {
        case .left:
            self.position = CGPoint(x: originalPosition.x - distance, y: originalPosition.y)
        case .right:
            self.position = CGPoint(x: originalPosition.x + distance, y: originalPosition.y)
        case .top:
            self.position = CGPoint(x: originalPosition.x, y: originalPosition.y + distance)
        case .bottom:
            self.position = CGPoint(x: originalPosition.x, y: originalPosition.y - distance)
        }
        
        let slide = SKAction.move(to: originalPosition, duration: duration)
        slide.timingMode = .easeOut
        self.run(slide)
    }
}

enum SlideDirection {
    case left, right, top, bottom
}

// MARK: - SKLabelNode Extensions
extension SKLabelNode {
    convenience init(text: String, fontSize: CGFloat, fontName: String = "Helvetica", color: SKColor = .white) {
        self.init(fontNamed: fontName)
        self.text = text
        self.fontSize = fontSize
        self.fontColor = color
    }
    
    func typeWriter(text: String, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        self.text = ""
        let characters = Array(text)
        let delay = duration / Double(characters.count)
        
        var index = 0
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { timer in
            if index < characters.count {
                self.text! += String(characters[index])
                index += 1
                SoundManager.shared.playEffect(.buttonTap)
            } else {
                timer.invalidate()
                completion?()
            }
        }
    }
    
    func animateNumber(to finalValue: Int, duration: TimeInterval = 1.0) {
        let startValue = Int(self.text ?? "0") ?? 0
        let difference = finalValue - startValue
        let steps = 60 // 60 FPS
        let stepValue = Double(difference) / Double(steps)
        let stepDuration = duration / Double(steps)
        
        var currentStep = 0
        let timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            let currentValue = startValue + Int(stepValue * Double(currentStep))
            
            if currentStep >= steps {
                self.text = "\(finalValue)"
                timer.invalidate()
            } else {
                self.text = "\(currentValue)"
            }
        }
    }
}

// MARK: - SKShapeNode Extensions
extension SKShapeNode {
    convenience init(circleOfRadius radius: CGFloat, color: SKColor, borderColor: SKColor? = nil, borderWidth: CGFloat = 0) {
        self.init(circleOfRadius: radius)
        self.fillColor = color
        if let borderColor = borderColor {
            self.strokeColor = borderColor
            self.lineWidth = borderWidth
        }
    }
    
    convenience init(rectOf size: CGSize, color: SKColor, borderColor: SKColor? = nil, borderWidth: CGFloat = 0) {
        self.init(rectOf: size)
        self.fillColor = color
        if let borderColor = borderColor {
            self.strokeColor = borderColor
            self.lineWidth = borderWidth
        }
    }
    
    func addGradient(colors: [SKColor], direction: GradientDirection = .vertical) {
        // Note: SpriteKit doesn't have built-in gradient support
        // This is a simplified implementation
        guard colors.count >= 2 else { return }
        
        // Create texture with gradient
        if let gradientTexture = ColorPalettes.createGradientTexture(colors: colors, size: frame.size) {
            self.fillTexture = gradientTexture
        }
    }
}

enum GradientDirection {
    case vertical, horizontal, diagonal
}

// MARK: - CGPoint Extensions
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    func angle(to point: CGPoint) -> CGFloat {
        return atan2(point.y - y, point.x - x)
    }
    
    func moved(by vector: CGVector) -> CGPoint {
        return CGPoint(x: x + vector.dx, y: y + vector.dy)
    }
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
}

// MARK: - CGVector Extensions
extension CGVector {
    var magnitude: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    var normalized: CGVector {
        let mag = magnitude
        return mag > 0 ? CGVector(dx: dx / mag, dy: dy / mag) : CGVector.zero
    }
    
    func rotated(by angle: CGFloat) -> CGVector {
        let cos = Foundation.cos(angle)
        let sin = Foundation.sin(angle)
        return CGVector(dx: dx * cos - dy * sin, dy: dx * sin + dy * cos)
    }
    
    static func + (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }
    
    static func - (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
    }
    
    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
}

// MARK: - SKColor Extensions
extension SKColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    var hexString: String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
    
    func lighter(by percentage: CGFloat = 0.2) -> SKColor {
        return adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 0.2) -> SKColor {
        return adjustBrightness(by: -abs(percentage))
    }
    
    private func adjustBrightness(by percentage: CGFloat) -> SKColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            brightness = max(0, min(1, brightness + percentage))
            return SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        return self
    }
}

// MARK: - Array Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    mutating func shuffle() {
        for i in stride(from: count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            swapAt(i, j)
        }
    }
    
    func shuffled() -> [Element] {
        var array = self
        array.shuffle()
        return array
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidUsername: Bool {
        let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePredicate = NSPredicate(format:"SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: self)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func truncated(to length: Int, addEllipsis: Bool = true) -> String {
        if count <= length {
            return self
        }
        
        let truncated = String(prefix(length))
        return addEllipsis ? truncated + "..." : truncated
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let week = components.weekOfYear, week >= 1 {
            return week == 1 ? "1 week ago" : "\(week) weeks ago"
        }
        
        if let day = components.day, day >= 1 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
    
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    func formattedDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func formattedPlayTime() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "<1m"
        }
    }
}

// MARK: - Int Extensions
extension Int {
    func formattedWithCommas() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    var ordinal: String {
        let suffix: String
        let lastDigit = self % 10
        let lastTwoDigits = self % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 13 {
            suffix = "th"
        } else {
            switch lastDigit {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        
        return "\(self)\(suffix)"
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    func setObject<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: key)
        } catch {
            print("Failed to encode object for key \(key): \(error)")
        }
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("Failed to decode object for key \(key): \(error)")
            return nil
        }
    }
}

// MARK: - Math Utilities
struct MathUtils {
    static func lerp(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        return from + (to - from) * progress
    }
    
    static func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
    }
    
    static func map(_ value: CGFloat, fromMin: CGFloat, fromMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
        let ratio = (value - fromMin) / (fromMax - fromMin)
        return toMin + ratio * (toMax - toMin)
    }
    
    static func randomFloat(min: CGFloat = 0, max: CGFloat = 1) -> CGFloat {
        return CGFloat.random(in: min...max)
    }
    
    static func randomInt(min: Int, max: Int) -> Int {
        return Int.random(in: min...max)
    }
    
    static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return point1.distance(to: point2)
    }
    
    static func angle(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return point1.angle(to: point2)
    }
}

// MARK: - Performance Utilities
struct PerformanceUtils {
    static func measure<T>(operation: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }
    
    static func debounce(delay: TimeInterval, action: @escaping () -> Void) -> () -> Void {
        var timer: Timer?
        
        return {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                action()
            }
        }
    }
}

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func playHaptic(_ feedbackType: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impact = UIImpactFeedbackGenerator(style: feedbackType)
        impact.impactOccurred()
    }
    
    func playNotificationHaptic(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(notificationType)
    }
    
    func playSelectionHaptic() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
}

extension HapticManager {
    func success() {
        playNotificationHaptic(.success)
    }
    
    func error() {
        playNotificationHaptic(.error)
    }
    
    func warning() {
        playNotificationHaptic(.warning)
    }
    
    func lightImpact() {
        playHaptic(.light)
    }
    
    func mediumImpact() {
        playHaptic(.medium)
    }
    
    func heavyImpact() {
        playHaptic(.heavy)
    }
}