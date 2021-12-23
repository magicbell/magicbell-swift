//
//  NotificationStoreObserver.swift
//  MagicBell
//
//  Created by Joan Martin on 13/12/21.
//

import Foundation

/// The store content delegate observer
public protocol NotificationStoreContentObserver: AnyObject {
    /// Notifies the store did fully reload.
    func didReloadStore(_ store: NotificationStore)
    /// Notifies the store did insert new notifications at certain indexes.
    func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int])
    /// Notifies the store did change notifications at certain indexes.
    func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int])
    /// Notifies the store did delete notifications at certain indexes.
    func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int])
}

/// The store count delegate observer
public protocol NotificationStoreCountObserver: AnyObject {
    /// Notifies the store did change the total count value
    func store(_ store: NotificationStore, didChangeTotalCount count: Int)
    /// Notifies the store did change the unread count value
    func store(_ store: NotificationStore, didChangeUnreadCount count: Int)
    /// Notifies the store did change the unseen count value
    func store(_ store: NotificationStore, didChangeUnseenCount count: Int)
}
