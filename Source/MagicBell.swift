//
//  MagicBell.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

public class MagicBell {
    // MARK: - Properties
    private static var magicBell: MagicBell = {
        MagicBell()
    }()

    // MARK: -
    public let sdkProvider: DefaultSDKModule // TODO: replace with SDKProvider

    // Initialization
    private init() {
        sdkProvider = DefaultSDKModule(environment: Environment(
            apiKey: "34ed17a8482e44c765d9e163015a8d586f0b3383",
            apiSecret: "72c5cdbba85d089d7f11ab090cb4c6773cbafaa8",
            baseUrl: URL(string: "https://api.magicbell.com")!,
            isHMACEnabled: false))
    }

    // MARK: - Accessors
    public static var shared: MagicBell = magicBell
}
