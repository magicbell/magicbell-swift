//
//  UserPreferences.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Foundation

public class UserPreferences {
    public private (set) var preferences: [String: Preferences]

    public func availableNotificationPreferences() -> [String] {
        Array(preferences.keys)
    }

    init(categories: [String: Preferences]) {
        self.preferences = categories
    }
}

public class Preferences {
    public var email: Bool
    public var inApp: Bool
    public var mobilePush: Bool
    public var webPush: Bool

    init(email: Bool, inApp: Bool, mobilePush: Bool, webPush: Bool) {
        self.email = email
        self.inApp = inApp
        self.mobilePush = mobilePush
        self.webPush = webPush
    }
}
