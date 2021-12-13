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

    /// MagicBell's default API URL
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
    ///   - apiSecret: The Api Secret of your account
    ///   - enableHMAC: Enables HMAC authentication. Default to false.
    ///   - baseUrl: The base url of the api server. Default to api.magicbell.com.
    ///   - logLevel: The log level accepts none or debug. Default to debug.
    public static func configure(
        apiKey: String,
        apiSecret: String? = nil,
        enableHMAC: Bool = false,
        baseUrl: URL = defaultBaseUrl,
        logLevel: LogLevel = .debug
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
        // TODO: teardown stores
        shared.stores.removeAll()
    }

    private var stores: [NotificationStore] = []

    /// Returns a notification store for the given predicate. The store instnace will be kept, and returned later if used an equal predicate.
    /// - Parameters:
    ///    - predicate: Notification store's predicate. Define an scope for the notification store. Read, Seen, Archive, Categories, Topics and inApp.
    /// - Returns: A `NotificationStore` with all the actions. MarkNotifications, MarkAllNotifications, FetchNotifications, ReloadStore.
    public static func storeFor(predicate: StorePredicate) -> NotificationStore {
        if let store = shared.stores.first(where: { $0.predicate.hashValue == predicate.hashValue }) {
            return store
        }
        let store = shared.sdkProvider.createStore(name: nil, predicate: predicate)
        shared.stores.append(store)
        return store
    }


    /// Sets the APN token for the current logged user. This token is revoked when logout is called. Once the user is registered from the notification, `didRegisterForRemoteNotificationsWithDeviceToken` is being called, retrieve the token and call setDeviceToken.
    /// - Parameters:
    ///     - deviceToken: String from the `didRegisterForRemoteNotificationsWithDeviceToken` AppDelegate method.
    public static func setDeviceToken(deviceToken: String) {
        shared.sdkProvider.getSendPushSubscriptionInteractor().execute(deviceTokenString: deviceToken)
    }

    /// Returns a dictionary with each category and notification preferences. Each category has four different channels: email, inApp, mobile push and web push.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    public static func obtainUserPreferences(completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        shared.sdkProvider.getUserPreferencesInteractor().execute().then { userPreferences in
            completion(.success(userPreferences))
        }.fail { error in
            completion(.failure(error))
        }
    }

    /// Updates all the user preferences.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    public static func updateUserPreferences(_ userPreferences: UserPreferences, completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        shared.sdkProvider.updateUserPreferencesInteractor().execute(userPreferences: userPreferences).then { userPreferences in
            completion(.success(userPreferences))
        }.fail { error in
            completion(.failure(error))
        }
    }

    /// Updates preferences for a specific category.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    public static func updateNotificationPreferences(_ preferences: Preferences, for category: String, completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        updateUserPreferences(UserPreferences(categories: [category: preferences]), completion: completion)
    }
}
