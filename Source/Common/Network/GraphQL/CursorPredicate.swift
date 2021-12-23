//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
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
