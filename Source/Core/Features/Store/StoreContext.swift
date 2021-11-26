//
//  NotificaitionGraphQLQuery.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

public struct StoreContext {
    public init(name: String, storePredicate: StorePredicate, storePagination: StorePagination) {
        self.name = name
        self.storePredicate = storePredicate
        self.storePagination = storePagination
    }

    public let name: String
    public let storePredicate: StorePredicate
    public let storePagination: StorePagination
}

public struct StorePredicate {
    public enum Read {
        case read,
             unread,
             unspecified
    }

    public enum Seen {
        case seen,
             unseen,
             unspecified
    }

    public enum Archived {
        case archived,
             unarchived,
             unspecified
    }

    public let read: Read
    public let seen: Seen
    public let archived: Archived
    public let categories: [String]
    public let topics: [String]
    public let inApp: String?

    public init(read: StorePredicate.Read = .unspecified,
                seen: StorePredicate.Seen = .unspecified,
                archived: StorePredicate.Archived = .unspecified,
                categories: [String] = [],
                topics: [String] = [],
                inApp: String? = nil) {
        self.read = read
        self.seen = seen
        self.archived = archived
        self.categories = categories
        self.topics = topics
        self.inApp = inApp
    }
}

public struct StorePagination {
    public enum Pagination {
        case next(String),
             previous(String),
             unspecified
    }

    public let pagination: Pagination
    public let first: Int?

    public init(pagination: StorePagination.Pagination = .unspecified,
                first: Int? = nil) {
        self.pagination = pagination
        self.first = first
    }
}
