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
        totalCountPublisher = CurrentValueSubject<Int, Never>(store.totalCount)
        unreadCountPublisher = CurrentValueSubject<Int, Never>(store.unreadCount)
        unseenCountPublisher = CurrentValueSubject<Int, Never>(store.unseenCount)
        notificationsPublisher = CurrentValueSubject<[Notification], Never>(store.allNotifications())

        store.addCountObserver(self)
        store.addContentObserver(self)
    }

    /// The total count publisher
    public let totalCountPublisher: CurrentValueSubject<Int, Never>
    /// The unread count publisher
    public let unreadCountPublisher: CurrentValueSubject<Int, Never>
    /// The unseen count publisher
    public let unseenCountPublisher: CurrentValueSubject<Int, Never>
    /// The list of notifications publisher
    public let notificationsPublisher: CurrentValueSubject<[Notification], Never>

    public func store(_ store: NotificationStore, didChangeTotalCount count: Int) {
        totalCountPublisher.send(count)
    }

    public func store(_ store: NotificationStore, didChangeUnreadCount count: Int) {
        unreadCountPublisher.send(count)
    }

    public func store(_ store: NotificationStore, didChangeUnseenCount count: Int) {
        unseenCountPublisher.send(count)
    }

    public func didReloadStore(_ store: NotificationStore) {
        totalCountPublisher.send(store.totalCount)
        unreadCountPublisher.send(store.unreadCount)
        unseenCountPublisher.send(store.unseenCount)
    }

    public func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int]) {
        notificationsPublisher.send(store.allNotifications())
    }

    public func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int]) {
        notificationsPublisher.send(store.allNotifications())
    }

    public func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int]) {
        notificationsPublisher.send(store.allNotifications())
    }
}
