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
    private let storeRealTime: StoreRealTime
    private let deletePushSubscriptionInteractor: DeletePushSubscriptionInteractor
    private let logger: Logger

    init(
        deleteUserConfig: DeleteConfigInteractor,
        deleteUserQuery: DeleteUserQueryInteractor,
        storeRealTime: StoreRealTime,
        deletePushSubscriptionInteractor: DeletePushSubscriptionInteractor,
        logger: Logger
    ) {
        self.deleteUserConfigInteractor = deleteUserConfig
        self.deleteUserQueryInteractor = deleteUserQuery
        self.storeRealTime = storeRealTime
        self.deletePushSubscriptionInteractor = deletePushSubscriptionInteractor
        self.logger = logger
    }

    func execute() {
        var error: Error?
        storeRealTime.stopListening()
        deletePushSubscriptionInteractor.execute().result.get(error: &error)
        deleteUserQueryInteractor.execute()
        deleteUserConfigInteractor.execute().result.get(error: &error)
        assert(error == nil, "No error must be produced upon deleting user data.")
        logger.info(tag: magicBellTag, "User has been logged out from MagicBell.")
    }
}
