//
//  DeleteUserQueryInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct DeleteUserQueryInteractor {
    private let deleteUserQuery: Interactor.DeleteByQuery

    init(deleteUserQuery: Interactor.DeleteByQuery) {
        self.deleteUserQuery = deleteUserQuery
    }

    func execute() {
        var error: Error?
        deleteUserQuery
            .execute(IdQuery("userQuery"), in: DirectExecutor())
            .result.get(error: &error)
    }
}
