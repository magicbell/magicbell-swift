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
    let sdkProvider: SDKComponent

    // Initialization
    private init() {
        sdkProvider = DefaultSDKModule(environment: Environment(apiKey: "34ed17a8482e44c765d9e163015a8d586f0b3383",
                apiSecret: "72c5cdbba85d089d7f11ab090cb4c6773cbafaa8",
                baseUrl: URL(string: "https://api.magicbell.com")!,
                isHMACEnabled: false))
    }

    // MARK: - Accessors
    public static var shared: MagicBell = magicBell

    public func getConfig() -> AnyGetDataSource<Config> {
        sdkProvider.getConfigDataSource()
    }

    public func getUserPreferences() -> AnyGetDataSource<UserPreferences> {
        sdkProvider.getUserPreferencesDataSource()
    }

    public func putUserPreferences() -> AnyPutDataSource<UserPreferences> {
        sdkProvider.getPutUserPreferencesDataSource()
    }

    public func getNotificationDataSource() -> AnyGetDataSource<Notification> {
        sdkProvider.getNotificationDataSource()
    }

    public func getActionNotificationDataSource() -> AnyPutDataSource<Void> {
        sdkProvider.getActionNotificationDataSource()
    }

    public func getDeleteNotificationDataSource() -> DeleteDataSource {
        sdkProvider.getDeleteNotificationDataSource()
    }

    public func getPushSubscriptionDataSource() -> AnyPutDataSource<PushSubscription> {
        sdkProvider.getPushSubscriptionDataSource()
    }

    public func getDeletePushSubscriptionDataSource() -> DeleteDataSource {
        sdkProvider.getDeletePushSubscriptionDataSource()
    }
}
