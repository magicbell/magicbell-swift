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
@testable import MagicBell
@testable import Harmony
import struct MagicBell.Notification


enum ForceProperty {
    case none
    case read
    case unread
    case seen
    case unseen
    case archived
    case unarchived
}

func anyNotification(predicate: StorePredicate, id: String?, forceProperty: ForceProperty) -> Notification {
    return Notification.createForPredicate(predicate, id: id, forceProperty: forceProperty)
}

extension Notification {
    static func createForPredicate(_ predicate: StorePredicate,
                                   id: String? = nil,
                                   forceProperty: ForceProperty) -> Notification {

        var read: Bool
        switch predicate.read {
        case .read:
            read = true
        case .unread:
            read = false
        case .unspecified:
            read = randomBool()
        }

        var seen: Bool
        switch predicate.seen {
        case .seen:
            seen = true
        case .unseen:
            seen = false
        case .unspecified:
            seen = randomBool()
        }

        var archived: Bool
        switch predicate.archived {
        case .archived:
            archived = true
        case .unarchived:
            archived = false
        case .unspecified:
            archived = randomBool()
        }

        switch forceProperty {
        case .none:
            break
        case .read:
            read = true
            seen = true
        case .unread:
            read = false
        case .seen:
            seen = true
        case .unseen:
            seen = false
            read = false
        case .archived:
            archived = true
        case .unarchived:
            archived = false
        }

        let category = predicate.categories.first
        let topic = predicate.topics.first

        return create(id: id ?? anyString(),
                      read: read,
                      seen: seen,
                      archived: archived,
                      category: category,
                      topic: topic)
    }

    static func create(
        id: String = "123456789",
        read: Bool = false,
        seen: Bool = false,
        archived: Bool = false,
        category: String? = nil,
        topic: String? = nil
    ) -> Notification {
        Notification(
                id: id,
                title: "Testing",
                actionURL: nil,
                content: "Lorem ipsum sir dolor amet",
                category: category,
                topic: topic,
                customAttributes: nil,
                recipient: nil,
                seenAt: seen || read ? Date() : nil,
                sentAt: Date(),
                readAt: read ? Date() : nil,
                archivedAt: archived ? Date() : nil
        )
    }
}
