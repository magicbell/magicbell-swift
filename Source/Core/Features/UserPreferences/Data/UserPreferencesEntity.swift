//
//  UserPreferences.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation

public struct UserPreferencesEntity: Codable {

    public var preferences: [String: PreferencesEntity]?

    enum ContainerKeys: String, CodingKey {
        case notificationPreferences = "notification_preferences"
    }

    enum CodingKeys: String, CodingKey {
        case categories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationPreferences)
        preferences = try values.decode([String: PreferencesEntity].self, forKey: .categories)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var values = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationPreferences)
        try values.encode(preferences, forKey: .categories)
    }

    init(preferences: [String: PreferencesEntity]) {
        self.preferences = preferences
    }
}

public struct PreferencesEntity: Codable {

    public var email: Bool
    public var inApp: Bool
    public var mobilePush: Bool
    public var webPush: Bool

    enum CodingKeys: String, CodingKey {
        case email
        case inApp = "in_app"
        case mobilePush = "mobile_push"
        case webPush = "web_push"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        email = try values.decodeIfPresent(Bool.self, forKey: .email) ?? false
        inApp = try values.decodeIfPresent(Bool.self, forKey: .inApp) ?? false
        mobilePush = try values.decodeIfPresent(Bool.self, forKey: .mobilePush) ?? false
        webPush = try values.decodeIfPresent(Bool.self, forKey: .webPush) ?? false
    }

    init(email: Bool, inApp: Bool, mobilePush: Bool, webPush: Bool) {
        self.email = email
        self.inApp = inApp
        self.mobilePush = mobilePush
        self.webPush = webPush
    }
}
