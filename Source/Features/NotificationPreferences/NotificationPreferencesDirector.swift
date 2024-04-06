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
import Harmony
import Combine

public protocol NotificationPreferencesDirector {
    
    /// Fetches the notification preferences for the current user.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `NotificationPreferences`.
    func fetch(completion: @escaping(Result<NotificationPreferences, Error>) -> Void)
    
    /// Updates the users notification preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `NotificationPreferences`.
    func update(_ notificationPreferences: NotificationPreferences, completion: @escaping(Result<NotificationPreferences, Error>) -> Void)
}

public extension NotificationPreferencesDirector {
    /// Fetches the users notification preferences.
    /// - Returns: A future with the users notification preferences or an error
    @available(iOS 13.0, *)
    func fetch() -> Combine.Future<NotificationPreferences, Error> {
        return Future { promise in
            self.fetch { result in
                promise(result)
            }
        }
    }
    
    /// Updates the users notification preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Returns: A future with the users notification preferences or an error
    @available(iOS 13.0, *)
    @discardableResult
    func update(_ notificationPreferences: NotificationPreferences) -> Combine.Future<NotificationPreferences, Error> {
        return Future { promise in
            self.update(notificationPreferences) { result in
                promise(result)
            }
        }
    }
}

struct DefaultNotificationPreferencesDirector: NotificationPreferencesDirector {
    
    private let logger: Logger
    private let userQuery: UserQuery
    private let getNotificationPreferencesInteractor: GetNotificationPreferencesInteractor
    private let updateNotificationPreferencesInteractor: UpdateNotificationPreferencesInteractor
    
    init(
        logger: Logger,
        userQuery: UserQuery,
        getNotificationPreferencesInteractor: GetNotificationPreferencesInteractor,
        updateNotificationPreferencesInteractor: UpdateNotificationPreferencesInteractor
    ) {
        self.logger = logger
        self.userQuery = userQuery
        self.getNotificationPreferencesInteractor = getNotificationPreferencesInteractor
        self.updateNotificationPreferencesInteractor = updateNotificationPreferencesInteractor
    }
    
    
    func fetch(completion: @escaping(Result<NotificationPreferences, Error>) -> Void) {
        getNotificationPreferencesInteractor.execute(userQuery: userQuery)
            .then { notificationPreferences in
                completion(.success(notificationPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }
    
    func update(_ notificationPreferences: NotificationPreferences, completion: @escaping(Result<NotificationPreferences, Error>) -> Void) {
        updateNotificationPreferencesInteractor.execute(notificationPreferences, userQuery: userQuery)
            .then { notificationPreferences in
                completion(.success(notificationPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }
}
