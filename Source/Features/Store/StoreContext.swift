//
//  StoreRequest.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

struct StoreContext {
    let name: String
    let store: StorePredicate
    let cursor: CursorPredicate
    
    init(
        _ name: String,
        _ store: StorePredicate,
        _ cursor: CursorPredicate
    ) {
        self.name = name
        self.store = store
        self.cursor = cursor
    }
}
