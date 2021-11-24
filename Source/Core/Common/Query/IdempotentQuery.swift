//
//  IdempotentQuery.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

public class IdempotentQuery: Query {
    var idempotentKey: String = UUID().uuidString
}
