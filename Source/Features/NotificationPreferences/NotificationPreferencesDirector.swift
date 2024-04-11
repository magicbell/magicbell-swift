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
    
    /// Updates the users notification preferences.
    ///
    /// - Important: Labels passed in categories and channels will be ignored, as the PUT endpoint does expect them.
    ///
    /// - SeeAlso: `update(categorySlug:channelSlug:enabled:completion:)` for a convenience function to update a single channel without having to construct an entire `NotificationPreferences` object
    ///
    /// - Parameters:
    ///     - notificationPreferences: Notificiation preferences to be updated. This can be partial subset of all categories or channels. The update will only affect what is included in the object.
    ///     - completion: Closure with a `Result`. Success returns `NotificationPreferences`.
    func update(_ notificationPreferences: NotificationPreferences, completion: @escaping(Result<NotificationPreferences, Error>) -> Void)
    
    
    /// Updates a single channel in a category
    ///
    /// - Parameters:
    ///     - categorySlug: A `String` identifying the category which contains the channel to update.
    ///     - channelSlug: A `String` identifying the channel to be updated.
    ///     - enabled: A `Bool` indicating wether the channel should be enabled or not.
    ///     - completion: Closure with a `Result`. Success returns the full `NotificationPreferences` containing all categories and channels.
    func update(categorySlug: String, channelSlug: String, enabled: Bool, completion: @escaping(Result<NotificationPreferences, Error>) -> Void)
}

// Combine API
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
    
    /// Updates the users notification preferences.
    ///
    /// - Important: Labels passed in categories and channels will be ignored, as the PUT endpoint does expect them.
    ///
    /// - SeeAlso: `update(categorySlug:channelSlug:enabled:)` for a convenience function to update a single channel without having to construct an entire `NotificationPreferences` object
    ///
    /// - Parameters:
    ///   - notificationPreferences: Notificiation preferences to be updated. This can be partial subset of all categories or channels. The update will only affect what is included in the object.
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
    
    /// Updates a channel in the users notification preferences.
    ///
    /// - Parameters:
    ///     - categorySlug: A `String` identifying the category which contains the channel to update.
    ///     - channelSlug: A `String` identifying the channel to be updated.
    ///     - enabled: A `Bool` indicating wether the channel should be enabled or not.
    /// - Returns: A future with the users full notification preferences, containing all categories and channels or an error
    @available(iOS 13.0, *)
    @discardableResult
    func update(categorySlug: String, channelSlug: String, enabled: Bool) -> Combine.Future<NotificationPreferences, Error> {
        return Future { promise in
            self.update(categorySlug: categorySlug, channelSlug: channelSlug, enabled: enabled) { result in
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
    
    func update(categorySlug: String, channelSlug: String, enabled: Bool, completion: @escaping(Result<NotificationPreferences, Error>) -> Void) {
        // Hack Alert:
        // The put API does not require passing a label for categories and channels.
        // The Harmony framework expects the GET and PUT datasources to have the same type though, so we are forced to have a label for PUT as well
        // @see: `Get.T == T, Put.T == T` in this code: https://github.com/mobilejazz/harmony-swift/blob/a00a498c7432d25c43f84a0736d3f7d4f40809ae/Sources/Harmony/Data/DataSource/Future/DataSourceAssembler.swift#L22
        // The label will be ignored when encoding NotificationPreferencesEntity, so we are free to pass an empty string here
        let dummyLabel = ""
        
        let channel = Channel(slug: channelSlug, label: dummyLabel, enabled: enabled)
        let category = Category(slug: categorySlug, label: dummyLabel, channels: [channel])
        self.update(NotificationPreferences(categories: [category]), completion: completion)
    }
}
