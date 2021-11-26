//
//  Store.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation

public struct Store: Codable {
    enum CodingKeys: String, CodingKey {
        case edges
        case pageInfo
        case totalCount
        case unreadCount
        case unseenCount
    }

    public let edges: [Edge]
    public let pageInfo: PageInfo
    public let totalCount: Int
    public let unreadCount: Int
    public let unseenCount: Int
}

// Notification + Cursor
public struct Edge: Codable {
    public let cursor: String
    public let notification: Notification

    enum CodingKeys: String, CodingKey {
        case cursor
        case notification = "node"
    }
}

// MARK: - PageInfo
public struct PageInfo: Codable {
    public let endCursor: String?
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool
    public let startCursor: String?
}
