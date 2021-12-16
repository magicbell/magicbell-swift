//
//  UserBell.swift
//  MagicBell
//
//  Created by Javi on 15/12/21.
//

import Foundation

/// The MagicBell authenticated user.
/// Entry point to access notifications and manipulate other user-based resources.
public class UserBell {
    private let userQuery: UserQuery
    private var internalStoreDirector: InternalStoreDirector
    /// The user preferences director.
    public private(set) var userPreferences: UserPreferencesDirector
    private(set) var pushSubscription: PushSubscriptionDirector

    /// The store director.
    public var store: StoreDirector {
        internalStoreDirector
    }

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
