//
//  UserPreferences.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Foundation

/// The preferences of notifiations
public class Preferences {
    /// Email enabled
    public var email: Bool
    /// InApp enabled
    public var inApp: Bool
    /// Mobile push enabled
    public var mobilePush: Bool
    /// Web push enabled
    public var webPush: Bool

    /// Main initializer
    /// - Parameters:
    ///   - email: Email enabled
    ///   - inApp: InApp enabled
    ///   - mobilePush: Mobile push enabled
    ///   - webPush: Web push enabled
    public init(email: Bool, inApp: Bool, mobilePush: Bool, webPush: Bool) {
        self.email = email
        self.inApp = inApp
        self.mobilePush = mobilePush
        self.webPush = webPush
    }
}

/// The user prefrences object
public struct UserPreferences {
    public let preferences: [String: Preferences]

    /// Main initializer.
    /// - Parameter preferences: The list of preferences by category.
    public init(_ preferences: [String: Preferences]) {
        self.preferences = preferences
    }
}
