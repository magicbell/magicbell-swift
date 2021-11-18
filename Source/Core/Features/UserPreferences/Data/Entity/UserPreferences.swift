//
//  UserPreferences.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation

public struct UserPreferences: Codable {
    public var notificationPreferences: NotificationPreferences?

    enum CodingKeys: String, CodingKey {
        case notificationPreferences = "notification_preferences"
    }

}

public struct NotificationPreferences: Codable {
    public var categories: [String: Category]?

    enum CodingKeys: String, CodingKey {
        case categories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categories = try container.decode([String: Category].self, forKey: .categories)
    }
}

public struct Category: Codable {
    public var email, inApp, mobilePush, webPush: Bool?

    enum CodingKeys: String, CodingKey {
        case email
        case inApp = "in_app"
        case mobilePush = "mobile_push"
        case webPush = "web_push"
    }
}
