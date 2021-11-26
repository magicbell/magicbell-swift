//
//  StorePredicate.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

public struct StorePredicate {
    public enum Read {
        case read
        case unread
        case unspecified
    }

    public enum Seen {
        case seen
        case unseen
        case unspecified
    }

    public enum Archived {
        case archived
        case unarchived
        case unspecified
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
