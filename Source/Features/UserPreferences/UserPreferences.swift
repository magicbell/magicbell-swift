//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
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
