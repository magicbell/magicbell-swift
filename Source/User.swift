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

/// The MagicBell authenticated user.
/// Entry point to access notifications and manipulate other user-based resources.
public class User {
    private let userQuery: UserQuery
    private var internalStoreDirector: InternalStoreDirector
    public private(set) var preferences: NotificationPreferencesDirector
    private(set) var pushSubscription: PushSubscriptionDirector
    private(set) var apnsToken: APNSTokenDirector

    /// The store director.
    public var store: StoreDirector {
        internalStoreDirector
    }

    init(
        userQuery: UserQuery,
        store: InternalStoreDirector,
        preferences: NotificationPreferencesDirector,
        pushSubscription: PushSubscriptionDirector,
        apnsToken: APNSTokenDirector
    ) {
        self.userQuery = userQuery
        self.internalStoreDirector = store
        self.preferences = preferences
        self.pushSubscription = pushSubscription
        self.apnsToken = apnsToken
    }

    func sendDeviceToken(deviceToken: String) {
        apnsToken.registerAPNSToken(deviceToken)
        pushSubscription.sendPushSubscription(deviceToken)
    }

    func logout(deviceToken: String?) {
        internalStoreDirector.logout()
        if let deviceToken = deviceToken {
            // TODO: Delete apnsToken
            pushSubscription.deletePushSubscription(deviceToken)
        }
    }
}
