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
    private let storeRealTimeComponent: StoreRealTimeComponent

    init(logger: Logger,
         getUserConfig: GetConfigInteractor,
         storeUserQuery: StoreUserQueryInteractor,
         storeRealTimeComponent: StoreRealTimeComponent) {
        self.logger = logger
        self.getUserConfigInteractor = getUserConfig
        self.storeUserQueryInteractor = storeUserQuery
        self.storeRealTimeComponent = storeRealTimeComponent
    }

    func execute(userId: String) {
        execute(userQuery: UserQuery(externalId: userId))
    }

    func execute(email: String) {
        execute(userQuery: UserQuery(email: email))
    }

    func execute(email: String, userId: String) {
        execute(userQuery: UserQuery(externalId: userId, email: email))
    }

    private func execute(userQuery: UserQuery) {
        // First, store the user query to allow the rest of the SDK to operate
        storeUserQueryInteractor.execute(userQuery)

        // Then, attempt to fetch the config.
        // If it fails, it can be refetched later.
        getUserConfigInteractor
            .execute(forceRefresh: false, userQuery: userQuery)
            .then { _ in
                logger.info(tag: magicBellTag, "User config successfully retrieved upon login")
                storeRealTimeComponent.getStoreRealmTime().startListening()
            }
    }
}
