//
//  PushSubscriptionQuery.swift
//  MagicBell
//
//  Created by Joan Martin on 19/11/21.
//

import Harmony

public class DeletePushSubscriptionQuery: IdempotentQuery {
    public let userQuery: UserQuery
    public let deviceToken: String

    public init(userQuery: UserQuery, deviceToken: String) {
        self.userQuery = userQuery
        self.deviceToken = deviceToken
    }
}
