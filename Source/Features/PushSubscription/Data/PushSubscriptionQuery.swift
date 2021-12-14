//
//  PushSubscriptionQuery.swift
//  MagicBell
//
//  Created by Joan Martin on 19/11/21.
//

import Harmony

class RegisterPushSubscriptionQuery: Query {
    let user: UserQuery

    init(user: UserQuery) {
        self.user = user
    }
}

class DeletePushSubscriptionQuery: Query {
    let user: UserQuery
    let deviceToken: String

    init(user: UserQuery, deviceToken: String) {
        self.user = user
        self.deviceToken = deviceToken
    }
}
