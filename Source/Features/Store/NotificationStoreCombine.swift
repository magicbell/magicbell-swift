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

public extension NotificationStore {

    /// Clears the store and fetches first page.
    /// This method will notify the observers if changes are made into the store.
    /// - Returns: A future with the array of notifications or an error
    @available(iOS 13.0, *)
    @discardableResult
    func refresh() -> Future<[Notification], Error> {
        return Future { promise in
            self.refresh { result in
                promise(result)
            }
        }
    }

    /// Fetches the next page of notificatinos. It can be called multiple times to obtain all pages.
    /// This method will notify the observers if changes are made into the store.
    /// - Returns: A future with the array of notifications for the next page or an error
    @available(iOS 13.0, *)
    @discardableResult
    func fetch() -> Future<[Notification], Error> {
        return Future { promise in
            self.fetch { result in
                promise(result)
            }
        }
    }

    /// Deletes a notification.
    /// Calling this method triggers the observers to get notified upon deletion.
    /// - Parameters:
    ///    - notification: The Notification to be removed.
    /// - Returns: A future with an empty content if succes or an error
    @available(iOS 13.0, *)
    @discardableResult
    func delete(_ notification: Notification) -> Future<Void, Error> {
        return Future { promise in
            self.delete(notification) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(Void()))
                }
            }
        }
    }

    /// Marks a notification as read.
    /// - Parameters:
    ///    - notification: The notification
    /// - Returns: A future with the updated notification or an error
    @available(iOS 13.0, *)
    @discardableResult
    func markAsRead(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.markAsRead(notification) { result in
                promise(result)
            }
        }
    }

    /// Marks a notification as unread.
    /// - Parameters:
    ///    - notification: The notification
    /// - Returns: A future with the updated notification or an error
    @available(iOS 13.0, *)
    @discardableResult
    func markAsUnread(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.markAsUnread(notification) { result in
                promise(result)
            }
        }
    }

    /// Archives the notification.
    /// - Parameters:
    ///    - notification: The notification
    /// - Returns: A future with the updated notification or an error
    @available(iOS 13.0, *)
    @discardableResult
    func archive(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.archive(notification) { result in
                promise(result)
            }
        }
    }

    /// Unarchives a notification.
    /// - Parameters:
    ///    - notification: The notification
    /// - Returns: A future with the updated notification or an error
    @available(iOS 13.0, *)
    @discardableResult
    func unarchive(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.unarchive(notification) { result in
                promise(result)
            }
        }
    }

    /// Marks all notifications as read.
    /// - Returns: A future with an empty content if succes or an error
    @available(iOS 13.0, *)
    @discardableResult
    func markAllRead() -> Future<Void, Error> {
        return Future { promise in
            self.markAllRead { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(Void()))
                }
            }
        }
    }

    /// Marks all notifications as seen.
    /// - Returns: A future with an empty content if succes or an error
    @available(iOS 13.0, *)
    @discardableResult
    func markAllSeen() -> Future<Void, Error> {
        return Future { promise in
            self.markAllSeen { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(Void()))
                }
            }
        }
    }
}
