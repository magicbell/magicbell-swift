//
//  MagicBell.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

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
        sdkProvider = DefaultSDKModule(environment: environment)
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
}
