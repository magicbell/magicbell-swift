//
//  LoginInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct LoginInteractor {
    private let logger: Logger
    private let getUserConfig: GetUserConfigInteractor
    private let deleteUserConfig: DeleteUserConfigInteractor
    private let storeUserQuery: StoreUserQueryInteractor

    init(logger: Logger,
         getUserConfig: GetUserConfigInteractor,
         deleteUserConfig: DeleteUserConfigInteractor,
         storeUserQuery: StoreUserQueryInteractor) {
        self.logger = logger
        self.getUserConfig = getUserConfig
        self.deleteUserConfig = deleteUserConfig
        self.storeUserQuery = storeUserQuery
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
        storeUserQuery.execute(userQuery)

        // Then, attempt to fetch the config.
        // If it fails, it can be refetched later.
        getUserConfig
            .execute(forceRefresh: false, userQuery: userQuery)
            .then { _ in
                logger.info(tag: magicBellTag, "User config successfully retrieved upon login")
            }
    }
}
