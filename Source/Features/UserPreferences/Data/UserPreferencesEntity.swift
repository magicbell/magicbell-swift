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

struct UserPreferencesEntity: Codable {

    var preferences: [String: PreferencesEntity]?

    enum ContainerKeys: String, CodingKey {
        case notificationPreferences = "notification_preferences"
    }

    enum CodingKeys: String, CodingKey {
        case categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationPreferences)
        preferences = try values.decode([String: PreferencesEntity].self, forKey: .categories)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var values = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationPreferences)
        try values.encode(preferences, forKey: .categories)
    }

    init(preferences: [String: PreferencesEntity]) {
        self.preferences = preferences
    }
}

struct PreferencesEntity: Codable {

    var email: Bool
    var inApp: Bool
    var mobilePush: Bool
    var webPush: Bool

    enum CodingKeys: String, CodingKey {
        case email
        case inApp = "in_app"
        case mobilePush = "mobile_push"
        case webPush = "web_push"
    }

    init(from decoder: Decoder) throws {
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
