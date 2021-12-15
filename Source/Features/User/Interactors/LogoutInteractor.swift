//
//  LogoutInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct LogoutInteractor {

    private let deleteUserConfigInteractor: DeleteConfigInteractor
    private let deleteUserQueryInteractor: DeleteUserQueryInteractor
    private let deletePushSubscriptionInteractor: DeletePushSubscriptionInteractor
    private let logger: Logger

    init(
        deleteUserConfig: DeleteConfigInteractor,
        deleteUserQuery: DeleteUserQueryInteractor,
        deletePushSubscriptionInteractor: DeletePushSubscriptionInteractor,
        logger: Logger
    ) {
        self.deleteUserConfigInteractor = deleteUserConfig
        self.deleteUserQueryInteractor = deleteUserQuery
        self.deletePushSubscriptionInteractor = deletePushSubscriptionInteractor
        self.logger = logger
    }

    func execute(userQuery: UserQuery) {
        deleteUserQueryInteractor.execute()

        deleteUserConfigInteractor.execute()
            .then { _ in
                logger.info(tag: magicBellTag, "UserConfig was deleted succesfully.")
            }.fail { error in
                assertionFailure("No error must be produced upon deleting user data.")
                logger.error(tag: magicBellTag, "UserConfig couldn't be deleted: \(error)")
            }
        logger.info(tag: magicBellTag, "User has been logged out from MagicBell.")
    }
}
