//
//  LogoutInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct LogoutInteractor {
    private let logger: Logger
    private let deleteUserConfig: DeleteUserConfigInteractor
    private let deleteUserQuery: DeleteUserQueryInteractor

    init(logger: Logger,
         deleteUserConfig: DeleteUserConfigInteractor,
         deleteUserQuery: DeleteUserQueryInteractor) {
        self.logger = logger
        self.deleteUserConfig = deleteUserConfig
        self.deleteUserQuery = deleteUserQuery
    }

    func execute() {
        deleteUserQuery.execute()
        var error: Error?
        deleteUserConfig.execute().result.get(error: &error)
        assert(error == nil, "No error must be produced upon deleting user data.")
        logger.info(tag: magicBellTag, "User has been logged out from MagicBell.")
    }
}
