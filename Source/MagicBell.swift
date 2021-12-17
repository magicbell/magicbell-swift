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

    /// MagicBell's default API URL. Defaults to https://api.magicbell.com.
    public static let defaultBaseUrl: URL = {
        // swiftlint:disable force_unwrapping
        return URL(string: "https://api.magicbell.com")!
    }()

    private let sdkProvider: SDKComponent

    private var users: [String: UserBell] = [:]
    private var deviceToken: String?
    
    /// Main initialization method.
    /// - Parameters:
    ///   - apiKey: The Api Key of your account
    ///   - apiSecret: The api secret of your account
    ///   - enableHMAC: Enables HMAC authentication. Default to `false`. If set to `true`, HMAC will be only enabled if api secret is provided.
    ///   - baseUrl: The base url of the api server. Default to `MagicBell.defaultBaseUrl`.
    ///   - logLevel: The log level accepts none or debug. Default to none.
    public init(
        apiKey: String,
        apiSecret: String? = nil,
        enableHMAC: Bool = false,
        baseUrl: URL = MagicBell.defaultBaseUrl,
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

    /// Creates or retrieve an existing userBell.
    /// - Parameters:
    ///   - email: The user's email
    /// - Returns:
    ///   - A instance of UserBell.
    public func forUser(email: String) -> UserBell {
        let userQuery = UserQuery(email: email)
        return getUser(userQuery)
    }

    /// Creates or retrieve an existing userBell.
    /// - Parameters:
    ///   - externalId: The user's identifier
    /// - Returns:
    ///   - A instance of UserBell.
    public func forUser(externalId: String) -> UserBell {
        let userQuery = UserQuery(externalId: externalId)
        return getUser(userQuery)
    }

    /// Creates or retrieve an existing userBell.
    /// - Parameters:
    ///   - email: The user's email
    ///   - externalId: The user's identifier
    /// - Returns:
    ///   - A instance of UserBell.
    public func forUser(email: String, externalId: String) -> UserBell {
        let userQuery = UserQuery(externalId: externalId, email: email)
        return getUser(userQuery)
    }

    /// Removes a userBell and stops all connections.
    /// - Parameters:
    ///   - email: The user's email
    public func removeUserFor(email: String) {
        let userQuery = UserQuery(email: email)
        removeUser(userQuery: userQuery)
    }

    /// Removes a userBell and stops all connections.
    /// - Parameters:
    ///   - externalId: The user's identifier
    public func removeUserFor(externalId: String) {
        let userQuery = UserQuery(externalId: externalId)
        removeUser(userQuery: userQuery)
    }

    /// Removes a userBell and stops all connections.
    /// - Parameters:
    ///   - email: The user's email
    ///   - externalId: The user's identifier
    public func removeUserFor(email: String, externalId: String) {
        let userQuery = UserQuery(externalId: externalId, email: email)
        removeUser(userQuery: userQuery)
    }

    private func getUser(_ userQuery: UserQuery) -> UserBell {
        if let user = users[userQuery.key] {
            return user
        }
        let userBell = UserBell(
            userQuery: userQuery,
            store: sdkProvider.getStoreComponent().storeDirector(with: userQuery),
            userPreferences: sdkProvider.getUserPreferencesComponent().userPreferencesDirector(with: userQuery),
            pushSubscription: sdkProvider.getPushSubscriptionComponent().pushSubscriptionDirector(with: userQuery)
        )
        users[userQuery.key] = userBell
        if let deviceToken = self.deviceToken {
            userBell.pushSubscription.sendPushSubscription(deviceToken)
        }
        return userBell
    }

    private func removeUser(userQuery: UserQuery) {
        if let user = users[userQuery.key] {
            user.logout(deviceToken: self.deviceToken)
            users.removeValue(forKey: userQuery.key)
        }
    }

    /// Sets the APN token for the current logged user. This token is revoked when logout is called.
    /// Once the user is registered from the notification, `didRegisterForRemoteNotificationsWithDeviceToken` is being called, retrieve the token and call setDeviceToken.
    /// - Parameters:
    ///     - deviceToken: The APN device token
    public func setDeviceToken(deviceToken: Data) {
        let token = String(deviceToken: deviceToken)
        self.deviceToken = token
        // If users are logged, try to send the device token for them
        users.values.forEach { userBell in
            userBell.pushSubscription.sendPushSubscription(token)
        }
    }
}
