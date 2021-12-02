//
//  GraphQLPredicate.swift
//  MagicBell
//
//  Created by Javi on 26/11/21.
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
            string.append("archive: true")
        case .unarchived:
            string.append("archive: false")
        case .unspecified:
            break
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
