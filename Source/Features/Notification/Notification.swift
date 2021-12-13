//
//  Notification.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation

public struct Notification: Codable {
    public let id: String
    public let title: String?
    public let actionURL: String?
    public let content, category, topic: String?
    public let recipient: Recipient?
    public var seenAt: Date?
    public let sentAt: Date
    public var readAt: Date?
    public var archivedAt: Date?

    enum ContainerKeys: String, CodingKey {
        case notification
    }

    enum CodingKeys: String, CodingKey {
        case id, title
        case actionURL = "action_url"
        case content, category, topic
        case recipient
        case seenAt = "seen_at"
        case sentAt = "sentAt"
        case readAt = "read_at"
        case archivedAt = "archived_at"
    }

    enum CodingKeysGraphQL: String, CodingKey {
        case id, title
        case actionURL = "actionUrl"
        case content, category, topic
        case recipient
        case seenAt
        case sentAt
        case readAt
        case archivedAt
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: ContainerKeys.self),
           let valuesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notification) {
            id = try valuesContainer.decode(String.self, forKey: .id)
            title = try valuesContainer.decodeIfPresent(String.self, forKey: .title)
            actionURL = try valuesContainer.decodeIfPresent(String.self, forKey: .actionURL)
            content = try valuesContainer.decodeIfPresent(String.self, forKey: .content)
            category = try valuesContainer.decodeIfPresent(String.self, forKey: .category)
            topic = try valuesContainer.decodeIfPresent(String.self, forKey: .topic)
            recipient = try valuesContainer.decodeIfPresent(Recipient.self, forKey: .recipient)
            seenAt = try valuesContainer.decodeIfPresent(Date.self, forKey: .seenAt)
            sentAt = try valuesContainer.decode(Date.self, forKey: .sentAt)
            readAt = try valuesContainer.decodeIfPresent(Date.self, forKey: .readAt)
            archivedAt = try valuesContainer.decodeIfPresent(Date.self, forKey: .archivedAt)
        } else {
            let values = try decoder.container(keyedBy: CodingKeysGraphQL.self)
            id = try values.decode(String.self, forKey: .id)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            actionURL = try values.decodeIfPresent(String.self, forKey: .actionURL)
            content = try values.decodeIfPresent(String.self, forKey: .content)
            category = try values.decodeIfPresent(String.self, forKey: .category)
            topic = try values.decodeIfPresent(String.self, forKey: .topic)
            recipient = try values.decodeIfPresent(Recipient.self, forKey: .recipient)
            seenAt = try values.decodeIfPresent(Date.self, forKey: .seenAt)
            sentAt = try values.decode(Date.self, forKey: .sentAt)
            readAt = try values.decodeIfPresent(Date.self, forKey: .readAt)
            archivedAt = try values.decodeIfPresent(Date.self, forKey: .archivedAt)
        }
    }

    public init(id: String, title: String? = nil, actionURL: String? = nil, content: String? = nil, category: String? = nil, topic: String? = nil, recipient: Recipient? = nil, seenAt: Date? = nil, sentAt: Date = Date(), readAt: Date? = nil, archivedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.actionURL = actionURL
        self.content = content
        self.category = category
        self.topic = topic
        self.recipient = recipient
        self.seenAt = seenAt
        self.sentAt = sentAt
        self.readAt = readAt
        self.archivedAt = archivedAt
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
