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

    /// The Store director. Use this instance to create and dispose stores.
    /// Note this attrtibute is null until a user is logged in.
    public private(set) var store: StoreDirector?
    public private(set) var userPreferences: UserPreferencesDirector?

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

    /// User identification login.
    /// - Parameters:
    ///   - email: The user's email
    public func login(email: String) {
        let login = sdkProvider.getUserComponent().getLoginInteractor()
        let userQuery = login.execute(email: email)
        store = sdkProvider.getStoreComponent().storeDirector(with: userQuery)
        userPreferences = sdkProvider.getUserPreferencesComponent().userPreferencesDirector(with: userQuery)
    }

    /// User identification login.
    /// - Parameters:
    ///   - userId: The user's identifier
    public func login(userId: String) {
        let login = sdkProvider.getUserComponent().getLoginInteractor()
        let userQuery = login.execute(userId: userId)
        store = sdkProvider.getStoreComponent().storeDirector(with: userQuery)
    }

    /// User identification login.
    /// - Parameters:
    ///   - email: The user's email
    ///   - userId: The user's identifier
    public func login(email: String, userId: String) {
        let login = sdkProvider.getUserComponent().getLoginInteractor()
        let userQuery = login.execute(email: email, userId: userId)
        store = sdkProvider.getStoreComponent().storeDirector(with: userQuery)
    }

    /// Removes user identification.
    public func logout() {
        let logout = sdkProvider.getUserComponent().getLogoutInteractor()
        logout.execute()
        store = nil
    }

    /// Sets the APN token for the current logged user. This token is revoked when logout is called. Once the user is registered from the notification, `didRegisterForRemoteNotificationsWithDeviceToken` is being called, retrieve the token and call setDeviceToken.
    /// - Parameters:
    ///     - deviceToken: Data from the `didRegisterForRemoteNotificationsWithDeviceToken` AppDelegate method.
    public func setDeviceToken(deviceToken: Data) {
        let saveDeviceToken = sdkProvider.getPushSubscriptionComponent().getSaveDeviceTokenInteractor()
        saveDeviceToken.execute(deviceToken: deviceToken)
            .then { _ in
                let sendPushSubscription = self.sdkProvider.getPushSubscriptionComponent().getSendPushSubscriptionInteractor()
                _ = sendPushSubscription.execute()
            }
    }
}
