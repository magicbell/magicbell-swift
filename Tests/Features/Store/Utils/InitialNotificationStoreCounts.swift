//
//  InitialNotificationStoreCounts.swift
//  MagicBell
//
//  Created by Javi on 21/12/21.
//

import MagicBell

struct InitialNotificationStoreCounts {
    let totalCount: Int
    let unreadCount: Int
    let unseenCount: Int

    init(_ notificationStore: NotificationStore) {
        totalCount = notificationStore.totalCount
        unreadCount = notificationStore.unreadCount
        unseenCount = notificationStore.unseenCount
    }
}
