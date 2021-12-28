//
//  CombineNotificationStore.swift
//  MagicBell
//
//  Created by Joan Martin on 23/12/21.
//

import Foundation
import Combine

@available(iOS 13.0, *)
/// Combine Publisher of the different attributes a NotificationStore has.
/// Access a publisher via a notification store: `store.publisher()`
public class NotificationStorePublisher: ObservableObject, NotificationStoreCountObserver, NotificationStoreContentObserver {

    init(store: NotificationStore) {
        totalCount = store.totalCount
        unreadCount = store.unreadCount
        unseenCount = store.unseenCount
        hasNextPage = store.hasNextPage
        notifications = store.allNotifications()

        store.addCountObserver(self)
        store.addContentObserver(self)
    }

    /// The total count publisher
    @Published
    public var totalCount: Int
    /// The unread count publisher
    @Published
    public var unreadCount: Int
    /// The unseen count publisher
    @Published
    public var unseenCount: Int
    /// A boolean indicating if there is more content to load
    @Published
    public var hasNextPage: Bool
    /// The list of notifications publisher
    @Published
    public var notifications: [Notification]

    public func store(_ store: NotificationStore, didChangeTotalCount count: Int) {
        totalCount = count
    }

    public func store(_ store: NotificationStore, didChangeUnreadCount count: Int) {
        unreadCount = count
    }

    public func store(_ store: NotificationStore, didChangeUnseenCount count: Int) {
        unseenCount = count
    }

    public func didReloadStore(_ store: NotificationStore) {
        totalCount = store.totalCount
        unreadCount = store.unreadCount
        unseenCount = store.unseenCount
        notifications = store.allNotifications()
    }

    public func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int]) {
        notifications = store.allNotifications()
    }

    public func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int]) {
        notifications = store.allNotifications()
    }

    public func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int]) {
        notifications = store.allNotifications()
    }

    public func store(_ store: NotificationStore, didChangeHasNextPage hasNextPage: Bool) {
        self.hasNextPage = hasNextPage
    }
}
