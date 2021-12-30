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

    @available(iOS 13.0, *)
    @discardableResult
    func refresh() -> Future<[Notification], Error> {
        return Future { promise in
            self.refresh { result in
                switch result {
                case .success(let notifications):
                    promise(.success(notifications))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func fetch() -> Future<[Notification], Error> {
        return Future { promise in
            self.fetch { result in
                switch result {
                case .success(let notifications):
                    promise(.success(notifications))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func delete(_ notification: Notification) -> Future<Void, Error> {
        return Future { promise in
            self.delete(notification) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func markAsRead(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.markAsRead(notification) { result in
                switch result {
                case .success(let notification):
                    promise(.success((notification)))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func markAsUnread(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.markAsUnread(notification) { result in
                switch result {
                case .success(let notification):
                    promise(.success((notification)))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func archive(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.archive(notification) { result in
                switch result {
                case .success(let notification):
                    promise(.success((notification)))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func unarchive(_ notification: Notification) -> Future<Notification, Error> {
        return Future { promise in
            self.unarchive(notification) { result in
                switch result {
                case .success(let notification):
                    promise(.success((notification)))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func markAllRead() -> Future<Void, Error> {
        return Future { promise in
            self.markAllRead { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func markAllSeen() -> Future<Void, Error> {
        return Future { promise in
            self.markAllSeen { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
}
