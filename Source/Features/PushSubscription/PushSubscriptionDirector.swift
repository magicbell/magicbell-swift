//
//  PushSubscriptionDirector.swift
//  MagicBell
//
//  Created by Javi on 15/12/21.
//

import Foundation
import Harmony

protocol PushSubscriptionDirector {
    /// Sends a push subscription
    func sendPushSubscription(_ deviceToken: String)
    
    /// Deletes a push subscription
    func deletePushSubscription(_ deviceToken: String)
}

class DefaultPushSubscriptionDirector: PushSubscriptionDirector {

    private let logger: Logger
    private let userQuery: UserQuery
    private let sendPushSubscriptionInteractor: SendPushSubscriptionInteractor
    private let deletePushSubscriptionInteractor: DeletePushSubscriptionInteractor
    
    init(
        logger: Logger,
        userQuery: UserQuery,
        sendPushSubscriptionInteractor: SendPushSubscriptionInteractor,
        deletePushSubscriptionInteractor: DeletePushSubscriptionInteractor
    ) {
        self.logger = logger
        self.userQuery = userQuery
        self.sendPushSubscriptionInteractor = sendPushSubscriptionInteractor
        self.deletePushSubscriptionInteractor = deletePushSubscriptionInteractor
    }
    
    func sendPushSubscription(_ deviceToken: String) {
        sendPushSubscriptionInteractor
            .execute(deviceToken: deviceToken, userQuery: userQuery)
            .then { pushSubscription in
                self.logger.info(tag: magicBellTag, "Push subcription is created \(pushSubscription)")
            }.fail { error in
                self.logger.info(tag: magicBellTag, "Send device token failed: \(error)")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) { [weak self] in
                    self?.sendPushSubscription(deviceToken)
                }
            }
    }
    
    func deletePushSubscription(_ deviceToken: String) {
        deletePushSubscriptionInteractor.execute(deviceToken: deviceToken, userQuery: userQuery)
            .then { _ in
                self.logger.info(tag: magicBellTag, "Device token was unregistered succesfully")
            }.fail { error in
                self.logger.error(tag: magicBellTag, "Device token couldn't be unregistered: \(error)")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) { [weak self] in
                    self?.deletePushSubscription(deviceToken)
                }
            }
    }
}
