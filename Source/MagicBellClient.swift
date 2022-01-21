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

let magicBellTag = "MagicBell"

///
/// Public MagicBell SDK interface.
///
public class MagicBellClient {

    /// The MagicBell SDK version
    public static let version = "1.0.0-alpha.3"

    /// MagicBell's default API URL. Defaults to https://api.magicbell.com.
    public static let defaultBaseUrl: URL = {
        // swiftlint:disable force_unwrapping
        return URL(string: "https://api.magicbell.com")!
    }()

    private let sdkProvider: SDKComponent

    private var users: [String: User] = [:]
    private var deviceToken: String?

    /// Init of `MagicBellClient`.
    /// - Parameters:
    ///   - apiKey: The API Key of your MagicBell project.
    ///   - apiSecret: The API secret of your MagicBell project. Defaults to `nil`.
    ///   - enableHMAC: Use HMAC authentication. Defaults to `false`. If set to `true`, HMAC will be only enabled if the
    ///   API secret is set.
    ///   - baseUrl: URL of the API server. Defaults to `MagicBellClient.defaultBaseUrl`.
    ///   - logLevel: The log level, it accepts `.none` or `.debug`. Defaults to `.none`.
    public init(
        apiKey: String,
        apiSecret: String? = nil,
        enableHMAC: Bool = false,
        baseUrl: URL = MagicBellClient.defaultBaseUrl,
        logLevel: LogLevel = .none
    ) {
        sdkProvider = DefaultSDKModule(
            environment: Environment(
                apiKey: apiKey,
                apiSecret: apiSecret,
                baseUrl: baseUrl,
                isHMACEnabled: enableHMAC
            ),
            logLevel: logLevel
        )
    }

    /// Create or retrieve an existing MagicBell user.
    /// - Parameters:
    ///   - email: The user's email
    /// - Returns:
    ///   - An instance of `User`.
    public func forUser(email: String) -> User {
        let userQuery = UserQuery(email: email)
        return getUser(userQuery)
    }

    /// Create or retrieve an existing MagicBell user.
    /// - Parameters:
    ///   - externalId: The user's external ID
    /// - Returns:
    ///   - An instance of `User`.
    public func forUser(externalId: String) -> User {
        let userQuery = UserQuery(externalId: externalId)
        return getUser(userQuery)
    }

    /// Create or retrieve an existing MagicBell user.
    /// - Parameters:
    ///   - email: The user's email
    ///   - externalId: The user's external ID
    /// - Returns:
    ///   - An instance of `User`.
    public func forUser(email: String, externalId: String) -> User {
        let userQuery = UserQuery(externalId: externalId, email: email)
        return getUser(userQuery)
    }

    /// Remove a MagicBell user. All connections are stopped.
    /// - Parameters:
    ///   - email: The user's email
    public func removeUserFor(email: String) {
        let userQuery = UserQuery(email: email)
        removeUser(userQuery: userQuery)
    }

    /// Remove a MagicBell user. All connections are stopped.
    /// - Parameters:
    ///   - externalId: The user's external ID
    public func removeUserFor(externalId: String) {
        let userQuery = UserQuery(externalId: externalId)
        removeUser(userQuery: userQuery)
    }

    /// Remove a MagicBell user. All connections are stopped.
    /// - Parameters:
    ///   - email: The user's email
    ///   - externalId: The user's external ID
    public func removeUserFor(email: String, externalId: String) {
        let userQuery = UserQuery(externalId: externalId, email: email)
        removeUser(userQuery: userQuery)
    }

    private func getUser(_ userQuery: UserQuery) -> User {
        if let user = users[userQuery.key] {
            return user
        }

        let newUser = User(
            userQuery: userQuery,
            store: sdkProvider.getStoreComponent().storeDirector(with: userQuery),
            preferences: sdkProvider.getUserPreferencesComponent().userPreferencesDirector(with: userQuery),
            pushSubscription: sdkProvider.getPushSubscriptionComponent().pushSubscriptionDirector(with: userQuery)
        )
        users[userQuery.key] = newUser
        if let deviceToken = self.deviceToken {
            newUser.pushSubscription.sendPushSubscription(deviceToken)
        }

        return newUser
    }

    private func removeUser(userQuery: UserQuery) {
        if let user = users[userQuery.key] {
            user.logout(deviceToken: self.deviceToken)
            users.removeValue(forKey: userQuery.key)
        }
    }

    /// Set the APN device token for the current logged in user. This token is revoked on logout.
    /// Call this method with the device token once the user registers for push notifications, and
    /// `didRegisterForRemoteNotificationsWithDeviceToken` is called.
    /// - Parameters:
    ///     - deviceToken: The APN device token
    public func setDeviceToken(deviceToken: Data) {
        let token = String(deviceToken: deviceToken)
        self.deviceToken = token

        // If users are logged in, send the device token to the MagicBell server
        users.values.forEach { user in
            user.pushSubscription.sendPushSubscription(token)
        }
    }
}
