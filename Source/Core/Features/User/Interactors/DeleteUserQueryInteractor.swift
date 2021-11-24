//
//  DeleteUserQueryInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct DeleteUserQueryInteractor {
    private let deleteUserQueryInteractor: Interactor.DeleteByQuery

    init(deleteUserQuery: Interactor.DeleteByQuery) {
        self.deleteUserQueryInteractor = deleteUserQuery
    }

    func execute() {
        var error: Error?
        deleteUserQueryInteractor
            .execute(IdQuery("userQuery"), in: DirectExecutor())
            .result.get(error: &error)
    }
}
