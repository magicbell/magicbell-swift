//
//  Store.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation

struct StorePage: Codable {
    enum CodingKeys: String, CodingKey {
        case edges
        case pageInfo
        case totalCount
        case unreadCount
        case unseenCount
    }

    let edges: [Edge<Notification>]
    let pageInfo: PageInfo
    let totalCount: Int
    let unreadCount: Int
    let unseenCount: Int
}
