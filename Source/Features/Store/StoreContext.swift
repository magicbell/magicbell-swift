//
//  StoreRequest.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

public struct StoreContext {
    public let name: String
    public let store: StorePredicate
    public let cursor: CursorPredicate
    
    public init(_ name: String,
                _ store: StorePredicate,
                _ cursor: CursorPredicate) {
        self.name = name
        self.store = store
        self.cursor = cursor
    }
}
