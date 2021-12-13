//
//  NotificationStoreQuery.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

struct StoreQuery: Query {
    let contexts: [StoreContext]
    let userQuery: UserQuery

    init(name: String,
         storePredicate: StorePredicate,
         cursorPredicate: CursorPredicate,
         userQuery: UserQuery) {
        self.init(
            contexts: [
                StoreContext(name, storePredicate, cursorPredicate)
            ],
            userQuery: userQuery
        )
    }

    init(contexts: [StoreContext], userQuery: UserQuery) {
        self.contexts = contexts
        self.userQuery = userQuery
    }
}
