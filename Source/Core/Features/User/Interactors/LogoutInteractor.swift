//
//  LogoutInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct LogoutInteractor {
    private let logger: Logger
    private let deleteUserConfigInteractor: DeleteConfigInteractor
    private let deleteUserQueryInteractor: DeleteUserQueryInteractor

    init(logger: Logger,
         deleteUserConfig: DeleteConfigInteractor,
         deleteUserQuery: DeleteUserQueryInteractor) {
        self.logger = logger
        self.deleteUserConfigInteractor = deleteUserConfig
        self.deleteUserQueryInteractor = deleteUserQuery
    }

    func execute() {
        deleteUserQueryInteractor.execute()
        var error: Error?
        deleteUserConfigInteractor.execute().result.get(error: &error)
        assert(error == nil, "No error must be produced upon deleting user data.")
        logger.info(tag: magicBellTag, "User has been logged out from MagicBell.")
    }
}
