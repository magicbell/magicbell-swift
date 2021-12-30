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

extension StorePredicate: GraphQLRepresentable {
    var graphQLValue: String {
        var string: [String] = []

        switch read {
        case .read:
            string.append("read: true")
        case .unread:
            string.append("read: false")
        case .unspecified:
            break
        }

        switch seen {
        case .seen:
            string.append("seen: true")
        case .unseen:
            string.append("seen: false")
        case .unspecified:
            break
        }

        switch archived {
        case .archived:
            string.append("archived: true")
        case .unarchived:
            string.append("archived: false")
        }

        if !categories.isEmpty {
            string.append("categories:[\(categories.map { "\"\($0)\"" }.joined(separator: ", "))]")
        }

        if !topics.isEmpty {
            string.append("topics:[\(topics.map { "\"\($0)\"" }.joined(separator: ", "))]")
        }

        return string.joined(separator: ", ")
    }
}


extension StoreContext: GraphQLRepresentable {
    var graphQLValue: String {
        let storePredicateString = store.graphQLValue
        let cursorPredicateString = cursor.graphQLValue
        return " \(name):notifications (\(storePredicateString) \(cursorPredicateString)) { ...notification }"
    }
}

extension StoreQuery: GraphQLRepresentable {
    var graphQLValue: String {
        return contexts.map { context in
            context.graphQLValue
        }.joined(separator: "\n")
    }
}
