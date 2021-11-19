//
//  Notification.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation

public struct Notification: Codable {
    let id, title: String?
    let actionURL: String?
    let content, category, topic: String?
    let customAttributes: NotificationCustomAttributes?
    let recipient: Recipient
    let seenAt: Int?
    let sentAt: Int?
    let readAt: Int?
    let archivedAt: Int?

    enum ContainerKeys: String, CodingKey {
        case notification
    }

    enum CodingKeys: String, CodingKey {
        case id, title
        case actionURL = "action_url"
        case content, category, topic
        case customAttributes = "custom_attributes"
        case recipient
        case seenAt = "seen_at"
        case sentAt = "sent_at"
        case readAt = "read_at"
        case archivedAt = "archived_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notification)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        actionURL = try values.decodeIfPresent(String.self, forKey: .actionURL)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        topic = try values.decodeIfPresent(String.self, forKey: .topic)
        customAttributes = try values.decodeIfPresent(NotificationCustomAttributes.self, forKey: .customAttributes)
        recipient = try values.decode(Recipient.self, forKey: .recipient)
        seenAt = try values.decodeIfPresent(Int.self, forKey: .seenAt)
        sentAt = try values.decodeIfPresent(Int.self, forKey: .sentAt)
        readAt = try values.decodeIfPresent(Int.self, forKey: .readAt)
        archivedAt = try values.decodeIfPresent(Int.self, forKey: .archivedAt)
    }
}

public struct NotificationCustomAttributes: Codable {
    let encoding, wordCount: String?

    enum CodingKeys: String, CodingKey {
        case encoding
        case wordCount = "word_count"
    }
}

public struct Recipient: Codable {
    let id, email: String?
    let externalID, firstName, lastName: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case externalID = "external_id"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
