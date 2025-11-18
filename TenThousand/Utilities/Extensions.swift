//
//  Extensions.swift
//  TenThousand
//
//  Created by Tim Isaev on 18.11.2025.
//

import Foundation
import SwiftUI

// MARK: - RectCorner Types

struct RectCorner: OptionSet {
    let rawValue: Int

    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)

    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct NSRectCorner: OptionSet {
    let rawValue: Int

    static let topLeft = NSRectCorner(rawValue: 1 << 0)
    static let topRight = NSRectCorner(rawValue: 1 << 1)
    static let bottomLeft = NSRectCorner(rawValue: 1 << 2)
    static let bottomRight = NSRectCorner(rawValue: 1 << 3)
}

// MARK: - Date Extensions

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfWeek: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfWeek) ?? self
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }

    var startOfYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfYear: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfYear) ?? self
    }

    func timeRemaining(until endDate: Date) -> String {
        let timeInterval = endDate.timeIntervalSince(self)
        return formatTimeInterval(timeInterval)
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)

        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    var formattedTime: String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - View Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = NSBezierPath.roundedRectPath(
            in: rect,
            corners: corners.nsRectCorner,
            radius: radius
        )
        return Path(path.cgPath)
    }
}

extension RectCorner {
    var nsRectCorner: NSRectCorner {
        var corners: NSRectCorner = []
        if contains(.topLeft) { corners.insert(.topLeft) }
        if contains(.topRight) { corners.insert(.topRight) }
        if contains(.bottomLeft) { corners.insert(.bottomLeft) }
        if contains(.bottomRight) { corners.insert(.bottomRight) }
        return corners
    }
}

// MARK: - NSBezierPath Extension

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }

        return path
    }

    static func roundedRectPath(in rect: CGRect, corners: NSRectCorner, radius: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()

        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        if corners.contains(.topLeft) {
            path.move(to: CGPoint(x: topLeft.x + radius, y: topLeft.y))
        } else {
            path.move(to: topLeft)
        }

        // Top right corner
        if corners.contains(.topRight) {
            path.line(to: CGPoint(x: topRight.x - radius, y: topRight.y))
            path.curve(to: CGPoint(x: topRight.x, y: topRight.y + radius),
                  controlPoint1: topRight,
                  controlPoint2: topRight)
        } else {
            path.line(to: topRight)
        }

        // Bottom right corner
        if corners.contains(.bottomRight) {
            path.line(to: CGPoint(x: bottomRight.x, y: bottomRight.y - radius))
            path.curve(to: CGPoint(x: bottomRight.x - radius, y: bottomRight.y),
                  controlPoint1: bottomRight,
                  controlPoint2: bottomRight)
        } else {
            path.line(to: bottomRight)
        }

        // Bottom left corner
        if corners.contains(.bottomLeft) {
            path.line(to: CGPoint(x: bottomLeft.x + radius, y: bottomLeft.y))
            path.curve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - radius),
                  controlPoint1: bottomLeft,
                  controlPoint2: bottomLeft)
        } else {
            path.line(to: bottomLeft)
        }

        // Top left corner
        if corners.contains(.topLeft) {
            path.line(to: CGPoint(x: topLeft.x, y: topLeft.y + radius))
            path.curve(to: CGPoint(x: topLeft.x + radius, y: topLeft.y),
                  controlPoint1: topLeft,
                  controlPoint2: topLeft)
        } else {
            path.close()
        }

        return path
    }
}
