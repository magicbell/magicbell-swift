//
//  StorePageMotherObject.swift
//  MagicBell
//
//  Created by Javi on 20/12/21.
//

@testable import MagicBell
@testable import Harmony
import struct MagicBell.Notification

func givenPageStore(predicate: StorePredicate, size: Int, forceNotificationProperty: ForceProperty = .none) -> StorePage {
    return StorePage.create(edges: anyNotificationEdgeArray(predicate: predicate, size: size, forceNotificationProperty: forceNotificationProperty), pageInfo: anyPageInfo())
}

func anyPageStore() -> StorePage {
    return StorePage.create(edges: anyNotificationEdgeArray(predicate: StorePredicate(),
                                                            size: anyInt(minValue: 0, maxValue: 20),
                                                            forceNotificationProperty: .none), pageInfo: anyPageInfo())
}

extension StorePage {
    static func create(
        edges: [Edge<Notification>],
        pageInfo: PageInfo) -> StorePage {
            return StorePage(
                edges: edges,
                pageInfo: pageInfo,
                totalCount: edges.count,
                unreadCount: edges.filter { $0.node.readAt == nil }.count,
                unseenCount: edges.filter { $0.node.seenAt == nil }.count)
        }
}
