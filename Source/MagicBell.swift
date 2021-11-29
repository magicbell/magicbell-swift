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

    // TODO: Replace with SDKProvider
    // TODO: Make private (currently public for dev purposes)
    public let sdkProvider: DefaultSDKModule

    /// Main initializer
    /// - Parameter environment: The enviroment used in the SDK.
    private init(environment: Environment) {
        sdkProvider = DefaultSDKModule(
            environment: environment,
            logger: DeviceConsoleLogger()
        )
    }

    /// Pointer to the shared instance. Do not access this value. Instead, use the `shared` getter.
    private static var _instance: MagicBell?

    // TODO: Make private (currently public for dev purposes)
    /// Public access to the shared instance
    public static var shared: MagicBell {
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
    ///   - baseUrl: The base url of the api server. Default to api.magicbell.com.
    ///   - enableHMAC: Enables HMAC authentication. Default to true.
    public static func configure(
        apiKey: String,
        apiSecret: String,
        baseUrl: URL = defaultBaseUrl,
        enableHMAC: Bool = true
    ) {
        guard Thread.isMainThread else {
            fatalError("MagicBell.configure must be called from the main thread")
        }

        guard _instance == nil else {
            fatalError("MagicBell has already been initialized. MagicBell.configure can only be called once.")
        }
        _instance = MagicBell(environment: Environment(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: baseUrl,
            isHMACEnabled: enableHMAC
        ))
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
    }

    public static func createNotificationStore(name: String, predicate: StorePredicate) -> NotificationStore? {
        do {
            return try shared.sdkProvider.createNotificationStore(name: name, predicate: predicate)
        } catch {
            print("There is another storePredicate with the same. Use MagicBell.getNotificationStore(name) to use it.")
            return nil
        }
    }

    public static func getNotificationStore(name: String) -> NotificationStore? {
        return shared.sdkProvider.getNotificationStore(name: name)
    }
}
