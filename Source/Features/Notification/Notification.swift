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

///
/// A MagicBell notification object
///
public struct Notification: Codable {
    public let id: String
    public let title: String
    public let actionURL: String?
    public let content: String?
    public let category: String?
    public let topic: String?
    public let customAttributes: [String: Any]?
    public let recipient: Recipient?
    public internal(set) var seenAt: Date?
    public let sentAt: Date
    public internal(set) var readAt: Date?
    public internal(set) var archivedAt: Date?

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
        case sentAt = "sentAt"
        case readAt = "read_at"
        case archivedAt = "archived_at"
    }

    enum CodingKeysGraphQL: String, CodingKey {
        case id, title
        case actionURL = "actionUrl"
        case content, category, topic
        case customAttributes
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
            title = try valuesContainer.decode(String.self, forKey: .title)
            actionURL = try valuesContainer.decodeIfPresent(String.self, forKey: .actionURL)
            content = try valuesContainer.decodeIfPresent(String.self, forKey: .content)
            category = try valuesContainer.decodeIfPresent(String.self, forKey: .category)
            topic = try valuesContainer.decodeIfPresent(String.self, forKey: .topic)
            customAttributes = try valuesContainer.decodeIfPresent([String: Any].self, forKey: .customAttributes)
            recipient = try valuesContainer.decodeIfPresent(Recipient.self, forKey: .recipient)
            seenAt = try valuesContainer.decodeIfPresent(Date.self, forKey: .seenAt)
            sentAt = try valuesContainer.decode(Date.self, forKey: .sentAt)
            readAt = try valuesContainer.decodeIfPresent(Date.self, forKey: .readAt)
            archivedAt = try valuesContainer.decodeIfPresent(Date.self, forKey: .archivedAt)
        } else {
            let values = try decoder.container(keyedBy: CodingKeysGraphQL.self)
            id = try values.decode(String.self, forKey: .id)
            title = try values.decode(String.self, forKey: .title)
            actionURL = try values.decodeIfPresent(String.self, forKey: .actionURL)
            content = try values.decodeIfPresent(String.self, forKey: .content)
            category = try values.decodeIfPresent(String.self, forKey: .category)
            topic = try values.decodeIfPresent(String.self, forKey: .topic)
            customAttributes = try values.decodeIfPresent([String: Any].self, forKey: .customAttributes)
            recipient = try values.decodeIfPresent(Recipient.self, forKey: .recipient)
            seenAt = try values.decodeIfPresent(Date.self, forKey: .seenAt)
            sentAt = try values.decode(Date.self, forKey: .sentAt)
            readAt = try values.decodeIfPresent(Date.self, forKey: .readAt)
            archivedAt = try values.decodeIfPresent(Date.self, forKey: .archivedAt)
        }
    }

    public func encode(to encoder: Encoder) throws {
        // Do nothing
    }

    init(id: String, title: String, actionURL: String? = nil, content: String? = nil, category: String? = nil, topic: String? = nil,
         customAttributes: [String: Any]? = [:], recipient: Recipient? = nil, seenAt: Date? = nil, sentAt: Date, readAt: Date? = nil, archivedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.actionURL = actionURL
        self.content = content
        self.category = category
        self.topic = topic
        self.customAttributes = customAttributes
        self.recipient = recipient
        self.seenAt = seenAt
        self.sentAt = sentAt
        self.readAt = readAt
        self.archivedAt = archivedAt
    }
}

public struct Recipient: Codable {
    public let id, email: String?
    let externalID, firstName, lastName: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case externalID = "external_id"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
