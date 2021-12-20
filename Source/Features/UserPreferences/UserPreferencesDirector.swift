//
//  UserPreferencesDirector.swift
//  MagicBell
//
//  Created by Javi on 15/12/21.
//

import Foundation
import Harmony

public protocol UserPreferencesDirector {

    /// Returns the user preferences.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func fetch(completion: @escaping(Result<UserPreferences, Error>) -> Void)

    /// Updates the user preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func update(_ userPreferences: UserPreferences, completion: @escaping(Result<UserPreferences, Error>) -> Void)

    /// Returns the  preferences for a given category.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `Preferences` for the given category.
    func fetchPreferences(for category: String, completion: @escaping(Result<Preferences, Error>) -> Void)

    /// Updates the  preferences for a given category.
    /// - Parameters:
    ///   - preferences: The notification preferences for a given category.
    ///   - category: The category name.
    ///   - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func updatePreferences(_ preferences: Preferences, for category: String, completion: @escaping(Result<Preferences, Error>) -> Void)
}

struct DefaultUserPreferencesDirector: UserPreferencesDirector {

    private let logger: Logger
    private let userQuery: UserQuery
    private let getUserPreferencesInteractor: GetUserPreferencesInteractor
    private let updateUserPreferencesInteractor: UpdateUserPreferencesInteractor

    init(
        logger: Logger,
        userQuery: UserQuery,
        getUserPreferencesInteractor: GetUserPreferencesInteractor,
        updateUserPreferencesInteractor: UpdateUserPreferencesInteractor
    ) {
        self.logger = logger
        self.userQuery = userQuery
        self.getUserPreferencesInteractor = getUserPreferencesInteractor
        self.updateUserPreferencesInteractor = updateUserPreferencesInteractor
    }


    func fetch(completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        getUserPreferencesInteractor.execute(userQuery: userQuery)
            .then { userPreferences in
                completion(.success(userPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }

    func update(_ userPreferences: UserPreferences, completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        updateUserPreferencesInteractor.execute(userPreferences, userQuery: userQuery)
            .then { userPreferences in
                completion(.success(userPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }


    func fetchPreferences(for category: String, completion: @escaping(Result<Preferences, Error>) -> Void) {
        getUserPreferencesInteractor.execute(userQuery: userQuery)
            .map { userPreferences in
                guard let preferences = userPreferences.preferences[category] else {
                    throw MagicBellError("Notification preferences not found for category \(category)")
                }
                return preferences
            }.then { preferences in
                completion(.success(preferences))
            }.fail { error in
                completion(.failure(error))
            }
    }

    /// Updates the notification preferences for a given category.
    /// - Parameters:
    ///   - preferences: The notification preferences for a given category.
    ///   - category: The category name.
    ///   - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func updatePreferences(_ preferences: Preferences, for category: String, completion: @escaping(Result<Preferences, Error>) -> Void) {
        let userPreferences = UserPreferences([category: preferences])
        updateUserPreferencesInteractor.execute(userPreferences, userQuery: userQuery)
            .map { userPreferences in
                guard let preferences = userPreferences.preferences[category] else {
                    throw MagicBellError("Notification preferences not found for category \(category)")
                }
                return preferences
            }.then { preferences in
                completion(.success(preferences))
            }.fail { error in
                completion(.failure(error))
            }
    }
}