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
    let recipient: Recipient?
    let seenAt: Date?
    let sentAt: Date?
    let readAt: Date?
    let archivedAt: Date?

    enum ContainerKeys: String, CodingKey {
        case notification
    }

    enum CodingKeys: String, CodingKey {
        case id, title
        case actionURL = "action_url"
        case content, category, topic
        case recipient
        case seenAt = "seen_at"
        case sentAt = "sent_at"
        case readAt = "read_at"
        case archivedAt = "archived_at"
    }

    public init(from decoder: Decoder) throws {
        let values: KeyedDecodingContainer<CodingKeys>
        if let container = try? decoder.container(keyedBy: ContainerKeys.self),
           let valuesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notification){
            values = valuesContainer
        } else {
            values = try decoder.container(keyedBy: CodingKeys.self)
        }
        id = try values.decodeIfPresent(String.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        actionURL = try values.decodeIfPresent(String.self, forKey: .actionURL)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        topic = try values.decodeIfPresent(String.self, forKey: .topic)
        recipient = try values.decodeIfPresent(Recipient.self, forKey: .recipient)
        seenAt = try values.decodeIfPresent(Date.self, forKey: .seenAt)
        sentAt = try values.decodeIfPresent(Date.self, forKey: .sentAt)
        readAt = try values.decodeIfPresent(Date.self, forKey: .readAt)
        archivedAt = try values.decodeIfPresent(Date.self, forKey: .archivedAt)
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
