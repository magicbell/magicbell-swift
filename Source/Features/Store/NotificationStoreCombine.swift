//
//  NotificationStoreCombine.swift
//  MagicBell
//
//  Created by Javi on 27/12/21.
//

import Foundation
import Combine

public extension NotificationStore {
    @available(iOS 13.0, *)
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
    func markAsRead(_ notification: Notification) -> Future<Void, Error> {
        return Future { promise in
            self.markAsRead(notification) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    func markAsUnread(_ notification: Notification) -> Future<Void, Error> {
        return Future { promise in
            self.markAsUnread(notification) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    func archive(_ notification: Notification) -> Future<Void, Error> {
        return Future { promise in
            self.archive(notification) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    func unarchive(_ notification: Notification) -> Future<Void, Error> {
        return Future { promise in
            self.unarchive(notification) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }

    @available(iOS 13.0, *)
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
