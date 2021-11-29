//
//  Store.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation

public struct StorePage: Codable {
    enum CodingKeys: String, CodingKey {
        case edges
        case pageInfo
        case totalCount
        case unreadCount
        case unseenCount
    }

    public let edges: [Edge<Notification>]
    public let pageInfo: PageInfo
    public let totalCount: Int
    public let unreadCount: Int
    public let unseenCount: Int

    func obtainNotifications() -> [Notification] {
        return self.edges.map { $0.node }
    }
}
