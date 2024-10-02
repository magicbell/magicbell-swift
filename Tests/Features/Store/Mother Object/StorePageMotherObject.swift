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
import Harmony
import struct MagicBell.Notification

func givenPageStore(predicate: StorePredicate, size: Int, forceNotificationProperty: ForceProperty = .none) -> StorePage {
    let totalPages = anyInt(minValue: 1, maxValue: 10)
    return StorePage.create(notifications: anyNotificationArray(predicate: predicate,
                                                                size: size,
                                                                forceProperty: forceNotificationProperty),
                            currentPage: anyInt(minValue: totalPages, maxValue: 10),
                            totalPages: totalPages)
}

func anyPageStore() -> StorePage {
    let totalPages = anyInt(minValue: 1, maxValue: 10)
    return StorePage.create(notifications: anyNotificationArray(predicate: StorePredicate(),
                                                                size: anyInt(minValue: 0, maxValue: 20),
                                                                forceProperty: .none),
                            currentPage: anyInt(minValue: totalPages, maxValue: 10),
                            totalPages: totalPages)
}

extension StorePage {
    static func createNoNextPage(notifications: [Notification]) -> StorePage {
        create(notifications: notifications, currentPage: 1, totalPages: 1)
    }
    
    static func createHasNextPage(notifications: [Notification]) -> StorePage {
        create(notifications: notifications, currentPage: 1, totalPages: 2)
    }
    
    static func createAnyNextPage(notifications: [Notification]) -> StorePage {
        create(notifications: notifications, currentPage: 1, totalPages: anyInt(minValue: 1, maxValue: 2))
    }
    
    static func create(
        notifications: [Notification],
        currentPage: Int,
        totalPages: Int) -> StorePage {
            StorePage(
                notifications: notifications,
                totalCount: notifications.count,
                unreadCount: notifications.filter { $0.readAt == nil }.count,
                unseenCount: notifications.filter { $0.seenAt == nil }.count,
                totalPages: totalPages,
                perPage: notifications.count,
                currentPage: currentPage)
        }
}
