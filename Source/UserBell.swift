//
//  UserBell.swift
//  MagicBell
//
//  Created by Javi on 15/12/21.
//

import Foundation

public class UserBell {
    private let userQuery: UserQuery
    private var internalStoreDirector: InternalStoreDirector
    public var store: StoreDirector {
        internalStoreDirector
    }
    public private(set) var userPreferences: UserPreferencesDirector
    private(set) var pushSubscription: PushSubscriptionDirector

    init(
        userQuery: UserQuery,
        store: InternalStoreDirector,
        userPreferences: UserPreferencesDirector,
        pushSubscription: PushSubscriptionDirector
    ) {
        self.userQuery = userQuery
        self.internalStoreDirector = store
        self.userPreferences = userPreferences
        self.pushSubscription = pushSubscription
    }

    func sendDeviceToken(deviceToken: String) {
        pushSubscription.sendPushSubscription(deviceToken)
    }

    func logout(deviceToken: String?) {
        internalStoreDirector.logout()
        if let deviceToken = deviceToken {
            pushSubscription.deletePushSubscription(deviceToken)
        }
    }
}
