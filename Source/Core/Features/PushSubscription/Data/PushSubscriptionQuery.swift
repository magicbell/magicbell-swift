//
//  PushSubscriptionQuery.swift
//  MagicBell
//
//  Created by Joan Martin on 19/11/21.
//

import Harmony

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
