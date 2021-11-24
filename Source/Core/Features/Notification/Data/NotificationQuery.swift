//
//  NotificationQuer.swift
//  MagicBell
//
//  Created by Joan Martin on 19/11/21.
//

import Harmony

public class NotificationQuery: IdempotentQuery {
    public let userQuery: UserQuery
    public let notificationId: String

    public init(notificationId: String, userQuery: UserQuery) {
        self.notificationId = notificationId
        self.userQuery = userQuery
    }
}

public class NotificationActionQuery: NotificationQuery {
    public enum Action {
        case markAsRead,
             markAsUnread,
             archive,
             unarchive,
             markAllAsRead,
             markAllAsSeen
    }

    public let action: Action

    public init(action: Action, notificationId: String, userQuery: UserQuery) {
        self.action = action
        super.init(notificationId: notificationId, userQuery: userQuery)
    }
}
