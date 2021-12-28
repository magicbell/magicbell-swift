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
public class NotificationStorePublisher: NotificationStoreCountObserver, NotificationStoreContentObserver {

    init(store: NotificationStore) {
        totalCount = CurrentValueSubject<Int, Never>(store.totalCount)
        unreadCount = CurrentValueSubject<Int, Never>(store.unreadCount)
        unseenCount = CurrentValueSubject<Int, Never>(store.unseenCount)
        hasNextPage = CurrentValueSubject<Bool, Never>(store.hasNextPage)
        notifications = CurrentValueSubject<[Notification], Never>(store.allNotifications())

        store.addCountObserver(self)
        store.addContentObserver(self)
    }

    /// The total count publisher
    public let totalCount: CurrentValueSubject<Int, Never>
    /// The unread count publisher
    public let unreadCount: CurrentValueSubject<Int, Never>
    /// The unseen count publisher
    public let unseenCount: CurrentValueSubject<Int, Never>
    /// A boolean indicating if there is more content to load
    public let hasNextPage: CurrentValueSubject<Bool, Never>
    /// The list of notifications publisher
    public let notifications: CurrentValueSubject<[Notification], Never>

    public func store(_ store: NotificationStore, didChangeTotalCount count: Int) {
        totalCount.send(count)
    }

    public func store(_ store: NotificationStore, didChangeUnreadCount count: Int) {
        unreadCount.send(count)
    }

    public func store(_ store: NotificationStore, didChangeUnseenCount count: Int) {
        unseenCount.send(count)
    }

    public func didReloadStore(_ store: NotificationStore) {
        totalCount.send(store.totalCount)
        unreadCount.send(store.unreadCount)
        unseenCount.send(store.unseenCount)
        notifications.send(store.allNotifications())
    }

    public func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int]) {
        notifications.send(store.allNotifications())
    }

    public func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int]) {
        notifications.send(store.allNotifications())
    }

    public func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int]) {
        notifications.send(store.allNotifications())
    }

    public func store(_ store: NotificationStore, didChangeHasNextPage hasNextPage: Bool) {
        self.hasNextPage.send(hasNextPage)
    }
}
