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
