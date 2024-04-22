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
    public static let version = "2.0.0"

    private let sdkProvider: SDKComponent

    private var users: [String: User] = [:]
    private var deviceToken: String?

    /// Init of `MagicBellClient`.
    /// - Parameters:
    ///   - apiKey: The API Key of your MagicBell project.
    ///   - apiSecret: The API secret of your MagicBell project. Defaults to `nil`.
    ///   - baseUrl: URL of the API server. Defaults to `MagicBellClient.defaultBaseUrl`.
    ///   - logLevel: The log level, it accepts `.none` or `.debug`. Defaults to `.none`.
    public init(
        apiKey: String,
        // swiftlint:disable force_unwrapping
        baseUrl: URL = URL(string: "https://api.magicbell.com")!,
        logLevel: LogLevel = .none
    ) {
        sdkProvider = DefaultSDKModule(
            environment: Environment(
                apiKey: apiKey,
                baseUrl: baseUrl
            ),
            logLevel: logLevel
        )
    }

    /// Create or retrieve an existing MagicBell user.
    /// - Parameters:
    ///   - email: The user's email
    ///   - hmac: (Optional) Server generated hmac, used to authenticate the user. Will only be used when `enableHMAC` is set.
    /// - Returns:
    ///   - An instance of `User`.
    public func connectUser(email: String, hmac: String? = nil) -> User {
        let userQuery = UserQuery(email: email, hmac: hmac)
        return getUser(userQuery)
    }

    /// Create or retrieve an existing MagicBell user.
    /// - Parameters:
    ///   - externalId: The user's external ID
    ///   - hmac: (Optional) Server generated hmac, used to authenticate the user. Will only be used when `enableHMAC` is set.
    /// - Returns:
    ///   - An instance of `User`.
    public func connectUser(externalId: String, hmac: String? = nil) -> User {
        let userQuery = UserQuery(externalId: externalId, hmac: hmac)
        return getUser(userQuery)
    }

    /// Create or retrieve an existing MagicBell user.
    /// - Parameters:
    ///   - email: The user's email
    ///   - externalId: The user's external ID
    ///   - hmac: (Optional) Server generated hmac, used to authenticate the user. Will only be used when `enableHMAC` is set.
    /// - Returns:
    ///   - An instance of `User`.
    public func connectUser(email: String, externalId: String, hmac: String? = nil) -> User {
        let userQuery = UserQuery(externalId: externalId, email: email, hmac: hmac)
        return getUser(userQuery)
    }

    /// Remove a MagicBell user. All connections are stopped.
    /// - Parameters:
    ///   - email: The user's email
    public func disconnectUser(email: String) {
        let userKey = UserQuery.preferedKey(email: email, externalId: nil)
        removeUser(userKey: userKey)
    }

    /// Remove a MagicBell user. All connections are stopped.
    /// - Parameters:
    ///   - externalId: The user's external ID
    public func disconnectUser(externalId: String) {
        let userKey = UserQuery.preferedKey(email: nil, externalId: externalId)
        removeUser(userKey: userKey)
    }

    /// Remove a MagicBell user. All connections are stopped.
    /// - Parameters:
    ///   - email: The user's email
    ///   - externalId: The user's external ID
    public func disconnectUser(email: String, externalId: String) {
        let userKey = UserQuery.preferedKey(email: email, externalId: externalId)
        removeUser(userKey: userKey)
    }

    private func getUser(_ userQuery: UserQuery) -> User {
        if let user = users[userQuery.key] {
            return user
        }

        let newUser = User(
            userQuery: userQuery,
            store: sdkProvider.getStoreComponent().storeDirector(with: userQuery),
            preferences: sdkProvider.getNotificationPreferencesComponent().notificationPreferencesDirector(with: userQuery),
            pushSubscription: sdkProvider.getPushSubscriptionComponent().pushSubscriptionDirector(with: userQuery),
            apnsToken: sdkProvider.getAPNSTokenComponent().apnsTokenDirector(with: userQuery)
        )
        users[userQuery.key] = newUser
        if let deviceToken = self.deviceToken {
            newUser.apnsToken.registerAPNSToken(deviceToken)
            newUser.pushSubscription.sendPushSubscription(deviceToken)
        }

        return newUser
    }

    private func removeUser(userKey: String) {
        if let user = users[userKey] {
            user.logout(deviceToken: self.deviceToken)
            users.removeValue(forKey: userKey)
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
            user.apnsToken.registerAPNSToken(token)
            user.pushSubscription.sendPushSubscription(token)
        }
    }
}
