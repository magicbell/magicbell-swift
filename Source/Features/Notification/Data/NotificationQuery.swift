//
//  NotificationQuer.swift
//  MagicBell
//
//  Created by Joan Martin on 19/11/21.
//

import Harmony

class NotificationQuery: Query {
    let user: UserQuery
    let notificationId: String

    init(notificationId: String, userQuery: UserQuery) {
        self.notificationId = notificationId
        user = userQuery
    }
}

class NotificationActionQuery: NotificationQuery {
    enum Action {
        case markAsRead,
             markAsUnread,
             archive,
             unarchive,
             markAllAsRead,
             markAllAsSeen
    }

    let action: Action

    init(action: Action, notificationId: String, userQuery: UserQuery) {
        self.action = action
        super.init(notificationId: notificationId, userQuery: userQuery)
    }
}
