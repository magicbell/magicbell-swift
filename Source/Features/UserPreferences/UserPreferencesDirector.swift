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

public protocol UserPreferencesDirector {
    
    /// Fetches the user preferences.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func fetch(completion: @escaping(Result<UserPreferences, Error>) -> Void)
    
    /// Updates the user preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func update(_ userPreferences: UserPreferences, completion: @escaping(Result<UserPreferences, Error>) -> Void)
}

public extension UserPreferencesDirector {
    /// Fetches the user preferences.
    /// - Returns: A future with the user preferences or an error
    @available(iOS 13.0, *)
    func fetch() -> Combine.Future<UserPreferences, Error> {
        return Future { promise in
            self.fetch { result in
                promise(result)
            }
        }
    }
    
    /// Updates the user preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Returns: A future with the user preferences or an error
    @available(iOS 13.0, *)
    @discardableResult
    func update(_ userPreferences: UserPreferences) -> Combine.Future<UserPreferences, Error> {
        return Future { promise in
            self.update(userPreferences) { result in
                promise(result)
            }
        }
    }
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
}
