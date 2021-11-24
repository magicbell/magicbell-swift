//
//  UserQuery.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

public class UserQuery: KeyQuery {
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

    public var key: String {
        if let externalId = externalId {
            return externalId
        } else if let email = email {
            return email
        } else {
            Swift.fatalError("should never happen")
        }
    }
}
