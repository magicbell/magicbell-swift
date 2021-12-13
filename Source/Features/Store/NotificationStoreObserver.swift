//
//  NotificationStoreObserver.swift
//  MagicBell
//
//  Created by Joan Martin on 13/12/21.
//

import Foundation

public protocol NotificationStoreContentDelegate: AnyObject {
    func didReloadStore(_ store: NotificationStore)
    func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int])
    func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int])
    func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int])
}

public protocol NotificationStoreCountDelegate: AnyObject {
    func store(_ store: NotificationStore, didChangeTotalCount count: Int)
    func store(_ store: NotificationStore, didChangeUnreadCount count: Int)
    func store(_ store: NotificationStore, didChangeUnseenCount count: Int)
}
