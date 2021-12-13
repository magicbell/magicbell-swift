//
//  UserPreferences.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Foundation

public class Preferences {
    public var email: Bool
    public var inApp: Bool
    public var mobilePush: Bool
    public var webPush: Bool

    public init(email: Bool, inApp: Bool, mobilePush: Bool, webPush: Bool) {
        self.email = email
        self.inApp = inApp
        self.mobilePush = mobilePush
        self.webPush = webPush
    }
}

public struct UserPreferences {
    public let preferences: [String: Preferences]

    public init(_ preferences: [String: Preferences]) {
        self.preferences = preferences
    }
}
