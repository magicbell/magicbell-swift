//
//  UserQuery.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

class UserQuery: KeyQuery {
    let externalId: String?
    let email: String?
    let key: String

    init(externalId: String, email: String) {
        self.externalId = externalId
        self.email = email
        self.key = externalId
    }

    init(externalId: String) {
        self.externalId = externalId
        self.email = nil
        self.key = externalId
    }

    init(email: String) {
        self.externalId = nil
        self.email = email
        self.key = email
    }
}
