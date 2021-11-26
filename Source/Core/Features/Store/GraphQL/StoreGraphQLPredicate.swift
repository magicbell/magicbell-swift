//
//  GraphQLPredicate.swift
//  MagicBell
//
//  Created by Javi on 26/11/21.
//

import Foundation

protocol GraphQLPredicate {
    var query: String { get }
}

protocol GraphQLAttributeRepresentation {
    func stringRepresentation() -> String
}

struct StoreGraphQLPredicate: GraphQLPredicate {
    let storeContext: StoreContext

    var query: String {
        let storePredicateString = storeContext.storePredicate.stringRepresentation()
        let storePaginationString = storeContext.storePagination.stringRepresentation()
        return " \(storeContext.name):notifications (\(storePredicateString) \(storePaginationString)) { ...notification }"
    }
}

extension StorePredicate: GraphQLAttributeRepresentation {
    func stringRepresentation() -> String {
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

        if let inApp = inApp {
            string.append("inApp: \"\(inApp)\"")
        }

        return string.joined(separator: ", ")
    }
}

extension StorePagination: GraphQLAttributeRepresentation {
    func stringRepresentation() -> String {
        var string: [String] = []

        switch pagination {
        case .next(let after):
            string.append("after: \"\(after)\"")
        case .previous(let before):
            string.append("before: \"\(before)\"")
        case .unspecified:
            break
        }

        if let first = first {
            string.append("first: \(first)")
        }

        return string.joined(separator: ", ")
    }
}
