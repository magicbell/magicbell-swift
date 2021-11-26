//
//  NotificationStoreQuery.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

public struct NotificationStoreQuery: Query {

    public let name: String
    public let storeContext: StoreContext
    public let user: UserQuery

    public init(name: String, storeContext: StoreContext, user: UserQuery) {
        self.name = name
        self.storeContext = storeContext
        self.user = user
    }
}
