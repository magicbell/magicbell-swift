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
import Combine


/// Combine-based class to act as a view model or a publisher of changes
/// of the different attributes a NotificationStore has.
///
/// To use one, create an instance `NotificationStorePublisher(store)` and
/// observe changes directly on the different attirbutes of the class.
///
@available(iOS 13.0, *)
public class NotificationStorePublisher: ObservableObject, NotificationStoreCountObserver, NotificationStoreContentObserver {

    /// The notification store
    public let store: NotificationStore

    /// Default initializer
    /// - Parameter store: The notification store.
    public init(_ store: NotificationStore) {
        self.store = store

        totalCount = store.totalCount
        unreadCount = store.unreadCount
        unseenCount = store.unseenCount
        hasNextPage = store.hasNextPage
        notifications = store.notifications()

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

    // MARK: NotificationStoreCountObserver

    public func store(_ store: NotificationStore, didChangeTotalCount count: Int) {
        totalCount = count
    }

    public func store(_ store: NotificationStore, didChangeUnreadCount count: Int) {
        unreadCount = count
    }

    public func store(_ store: NotificationStore, didChangeUnseenCount count: Int) {
        unseenCount = count
    }

    // MARK: NotificationStoreContentObserver
    
    public func didReloadStore(_ store: NotificationStore) {
        // Reloading all counts
        totalCount = store.totalCount
        unreadCount = store.unreadCount
        unseenCount = store.unseenCount
        // Reloading array of notifications
        notifications = store.notifications()
    }

    public func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int]) {
        // Must insert objects by indexes in increasing order!
        // Sorting indexes from smaller to greater to insert.
        indexes.sorted(by: <).forEach { index in
            let notification = store[index]
            notifications.insert(notification, at: index)
        }
        notifications = store.notifications()
    }

    public func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int]) {
        // Modifications can be done at any index order!
        indexes.forEach { index in
            let notification = store[index]
            notifications[index] = notification
        }
    }

    public func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int]) {
        // Must delete objects by indexes in decreasing order!
        // Sorting indexes from greater to smaller to delete.
        indexes.sorted(by: >).forEach { index in
            notifications.remove(at: index)
        }
    }

    public func store(_ store: NotificationStore, didChangeHasNextPage hasNextPage: Bool) {
        self.hasNextPage = hasNextPage
    }
}
