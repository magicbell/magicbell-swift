//
//  MagicBellQuery.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

public class UserQuery: Query {
    let externalId: String?
    let email: String?

    public init(externalId: String, email: String) {
        self.externalId = externalId
        self.email = email
    }

    public init(externalId: String) {
        self.externalId = externalId
        email = nil
    }

    public init(email: String) {
        externalId = nil
        self.email = email
    }
}

public class NotificationQuery: Query {
    public let user: UserQuery
    public let notificationId: String

    public init(notificationId: String, userQuery: UserQuery) {
        self.notificationId = notificationId
        user = userQuery
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

public class RegisterPushSubscriptionQuery: Query {
    public let user: UserQuery

    public init(user: UserQuery) {
        self.user = user
    }
}

public class DeletePushSubscriptionQuery: Query {
    public let user: UserQuery
    public let deviceToken: String

    public init(user: UserQuery, deviceToken: String) {
        self.user = user
        self.deviceToken = deviceToken
    }
}
