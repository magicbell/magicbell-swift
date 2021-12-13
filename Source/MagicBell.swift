//
//  MagicBell.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

let magicBellTag = "MagicBell"

///
/// Public MagicBell SDK interface.
///
public class MagicBell {

    private let sdkProvider: SDKComponent

    private var stores: [NotificationStore] = []

    /// Main initializer
    /// - Parameter environment: The enviroment used in the SDK.
    private init(environment: Environment,
                 logLevel: LogLevel) {
        sdkProvider = DefaultSDKModule(
            environment: environment,
            logLevel: logLevel
        )
    }

    /// Pointer to the shared instance. Do not access this value. Instead, use the `shared` getter.
    private static var _instance: MagicBell?

    private static var shared: MagicBell {
        if let instance = _instance {
            return instance
        }
        fatalError("MagicBell hasn't been initialized yet. Please, call MagicBell.configure to initialize the SDK.")
    }

    /// MagicBell's default API URL. Defaults to https://api.magicbell.com.
    public static let defaultBaseUrl: URL = {
        if let url = URL(string: "https://api.magicbell.com") {
            return url
        }
        fatalError("Failed to initialize MagicBell's base URL")
    }()


    /// Main configuration method. Must be called prior to any call to MagicBell.
    /// This method can only be called once and must be called from the main thread.
    /// - Parameters:
    ///   - apiKey: The Api Key of your account
    ///   - apiSecret: The api secret of your account
    ///   - enableHMAC: Enables HMAC authentication. Default to `false`. If set to `true`, HMAC will be only enabled if api secret is provided.
    ///   - baseUrl: The base url of the api server. Default to `MagicBell.defaultBaseUrl`.
    ///   - logLevel: The log level accepts none or debug. Default to none.
    public static func configure(
        apiKey: String,
        apiSecret: String? = nil,
        enableHMAC: Bool = false,
        baseUrl: URL = defaultBaseUrl,
        logLevel: LogLevel = .none
    ) {
        guard Thread.isMainThread else {
            fatalError("MagicBell.configure must be called from the main thread")
        }

        guard _instance == nil else {
            fatalError("MagicBell has already been initialized. MagicBell.configure can only be called once.")
        }
        _instance = MagicBell(
            environment: Environment(
                apiKey: apiKey,
                apiSecret: apiSecret,
                baseUrl: baseUrl,
                isHMACEnabled: enableHMAC
            ),
            logLevel: logLevel
        )
    }

    /// User identification login.
    /// - Parameters:
    ///   - email: The user's email
    public static func login(email: String) {
        let login = shared.sdkProvider.getUserComponent().getLoginInteractor()
        login.execute(email: email)
    }

    /// User identification login.
    /// - Parameters:
    ///   - userId: The user's identifier
    public static func login(userId: String) {
        let login = shared.sdkProvider.getUserComponent().getLoginInteractor()
        login.execute(userId: userId)
    }

    /// User identification login.
    /// - Parameters:
    ///   - email: The user's email
    ///   - userId: The user's identifier
    public static func login(email: String, userId: String) {
        let login = shared.sdkProvider.getUserComponent().getLoginInteractor()
        login.execute(email: email, userId: userId)
    }

    /// Removes user identification.
    public static func logout() {
        let logout = shared.sdkProvider.getUserComponent().getLogoutInteractor()
        logout.execute()
        shared.stores.removeAll()
    }

    /// Returns a notification store for the given predicate. The store instnace will be kept, and returned later if used an equal predicate.
    /// - Parameters:
    ///    - predicate: Notification store's predicate. Define an scope for the notification store. Read, Seen, Archive, Categories, Topics and inApp.
    /// - Returns: A `NotificationStore` with all the actions. MarkNotifications, MarkAllNotifications, FetchNotifications, ReloadStore.
    public static func storeFor(predicate: StorePredicate) -> NotificationStore {
        if let store = shared.stores.first(where: { $0.predicate.hashValue == predicate.hashValue }) {
            return store
        }
        let store = shared.sdkProvider.getStoreComponent().createStore(name: nil, predicate: predicate)

        let realTimeStoreConnector = shared.sdkProvider.getStoreRealTimeComponent().getStoreRealmTime()
        realTimeStoreConnector.addObserver(store)

        shared.stores.append(store)
        return store
    }

    /// Deletes a notification store for the given predicate if exists.
    /// - Parameters:
    ///    - predicate: Notification store's predicate.
    public static func deleteStoreWith(predicate: StorePredicate) {
        if let storeIndex = shared.stores.firstIndex(where: { $0.predicate.hashValue == predicate.hashValue }) {
            let store = shared.stores[storeIndex]
            let realTimeStoreConnector = shared.sdkProvider.getStoreRealTimeComponent().getStoreRealmTime()
            realTimeStoreConnector.removeObserver(store)
            shared.stores.remove(at: storeIndex)
        }
    }

    /// Sets the APN token for the current logged user. This token is revoked when logout is called. Once the user is registered from the notification, `didRegisterForRemoteNotificationsWithDeviceToken` is being called, retrieve the token and call setDeviceToken.
    /// - Parameters:
    ///     - deviceToken: Data from the `didRegisterForRemoteNotificationsWithDeviceToken` AppDelegate method.
    public static func setDeviceToken(deviceToken: Data) {
        let saveDeviceToken = shared.sdkProvider.getPushSubscriptionComponent().getSaveDeviceTokenInteractor()
        saveDeviceToken.execute(deviceToken: deviceToken)
            .then { _ in
                let sendPushSubscription = shared.sdkProvider.getPushSubscriptionComponent().getSendPushSubscriptionInteractor()
                _ = sendPushSubscription.execute()
            }
    }

    /// Returns the user preferences.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    public static func obtainUserPreferences(completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        let getUserPreferences = shared.sdkProvider.getUserPreferencesComponent().getGetUserPreferencesInteractor()
        getUserPreferences.execute()
            .then { userPreferences in
                completion(.success(userPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }

    /// Updates the user preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    public static func updateUserPreferences(_ userPreferences: UserPreferences, completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        let updateUserPreferences = shared.sdkProvider.getUserPreferencesComponent().getUpdateUserPreferencesInteractor()
        updateUserPreferences.execute(userPreferences)
            .then { userPreferences in
                completion(.success(userPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }

    /// Returns the notification preferences for a given category.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `Preferences` for the given category.
    public static func obtainUserPreferences(for category: String, completion: @escaping(Result<Preferences, Error>) -> Void) {
        let getUserPreferences = shared.sdkProvider.getUserPreferencesComponent().getGetUserPreferencesInteractor()
        getUserPreferences.execute()
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
    public static func updateNotificationPreferences(_ preferences: Preferences, for category: String, completion: @escaping(Result<Preferences, Error>) -> Void) {
        let userPreferences = UserPreferences([category: preferences])
        let updateUserPreferences = shared.sdkProvider.getUserPreferencesComponent().getUpdateUserPreferencesInteractor()
        updateUserPreferences.execute(userPreferences)
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
