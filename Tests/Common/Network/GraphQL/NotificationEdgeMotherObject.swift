//
//  NotificationEdgeMotherObject.swift
//  MagicBell
//
//  Created by Javi on 20/12/21.
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
