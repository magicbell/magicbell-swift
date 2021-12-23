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
