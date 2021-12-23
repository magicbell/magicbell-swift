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

@testable import MagicBell
import struct MagicBell.Notification

enum AnyCursor: String {
    case any = "any-cursor"
    case firstPageCursor = "first-cursor"
    case secondPageCursor = "second-cursor"
}

func anyNotificationEdgeArray(predicate: StorePredicate, size: Int, forceNotificationProperty: ForceProperty) -> [Edge<Notification>] {
    (0..<size).map { anyNotificationEdge(predicate: predicate, id: String($0), forceNotificationProperty: forceNotificationProperty) }
}

func anyNotificationEdge(predicate: StorePredicate, id: String?, forceNotificationProperty: ForceProperty) -> Edge<Notification> {
    Edge(cursor: AnyCursor.any.rawValue, node: anyNotification(predicate: predicate, id: id, forceProperty: forceNotificationProperty))
}

extension Edge where T == Notification {
    static func create(
        cursor: String,
        notification: Notification
    ) -> Edge<Notification> {
        return Edge<Notification>(
            cursor: cursor,
            node: notification
        )
    }
}

extension Array where Element == Edge<Notification> {
    func totalCount() -> Int {
        return self.count
    }

    func unreadTotalCount() -> Int {
        return self.filter { $0.node.readAt == nil }.count
    }

    func unseenTotalCount() -> Int {
        return self.filter { $0.node.seenAt == nil }.count
    }
}
