//
//  Pagination.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

struct CursorPredicate: GraphQLRepresentable {
    enum Cursor {
        case next(String),
             previous(String),
             unspecified
    }

    let cursor: Cursor
    let size: Int?

    init(cursor: Cursor = .unspecified,
         size: Int? = nil) {
        self.cursor = cursor
        self.size = size
    }

    var graphQLValue: String {
        var string: [String] = []

        switch cursor {
        case .next(let after):
            string.append("after: \"\(after)\"")
        case .previous(let before):
            string.append("before: \"\(before)\"")
        case .unspecified:
            break
        }

        if let size = size {
            string.append("first: \(size)")
        }

        return string.joined(separator: ", ")
    }
}
