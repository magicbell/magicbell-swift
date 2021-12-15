//
//  LoginInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct LoginInteractor {
    private let logger: Logger
    private let getUserConfigInteractor: GetConfigInteractor
    private let storeUserQueryInteractor: StoreUserQueryInteractor
    private let sendPushSubscriptionInteractor: SendPushSubscriptionInteractor

    init(logger: Logger,
         getUserConfig: GetConfigInteractor,
         storeUserQuery: StoreUserQueryInteractor,
         sendPushSubscriptionInteractor: SendPushSubscriptionInteractor) {
        self.logger = logger
        self.getUserConfigInteractor = getUserConfig
        self.storeUserQueryInteractor = storeUserQuery
        self.sendPushSubscriptionInteractor = sendPushSubscriptionInteractor
    }

    func execute(userId: String) -> UserQuery {
        return execute(userQuery: UserQuery(externalId: userId))
    }

    func execute(email: String) -> UserQuery {
        return execute(userQuery: UserQuery(email: email))
    }

    func execute(email: String, userId: String) -> UserQuery {
        return execute(userQuery: UserQuery(externalId: userId, email: email))
    }

    private func execute(userQuery: UserQuery) -> UserQuery {
        // First, store the user query to allow the rest of the SDK to operate
        storeUserQueryInteractor.execute(userQuery)

        // Then, attempt to fetch the config.
        // If it fails, it can be refetched later.
        getUserConfigInteractor
            .execute(forceRefresh: false, userQuery: userQuery)
            .then { _ in
                self.logger.info(tag: magicBellTag, "User config successfully retrieved upon login")
            }

        sendPushSubscriptionInteractor
            .execute(userQuery: userQuery)
            .then { pushSubscription in
                logger.info(tag: magicBellTag, "Push subcription is created \(pushSubscription)")
            }.fail { error in
                switch error {
                case is CoreError.NotFound:
                    // Nothing to be done. Token might not exist yet.
                    break
                default:
                    logger.info(tag: magicBellTag, "Send device token failed: \(error)")
                }
            }

        return userQuery
    }
}
