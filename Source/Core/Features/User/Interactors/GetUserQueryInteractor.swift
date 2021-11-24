//
//  GetUserQueryInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct GetUserQueryInteractor {
    private let getUserQuery: Interactor.GetByQuery<UserQuery>

    init(getUserQuery: Interactor.GetByQuery<UserQuery>) {
        self.getUserQuery = getUserQuery
    }

    func execute() throws -> UserQuery {
        return try getUserQuery
            .execute(IdQuery("userQuery"), in: DirectExecutor())
            .mapError { error in
                if error is CoreError.NotFound {
                    return MagicBellError("Can't perform action because user is not identified. Please, call MagicBell.login to identify a user.")
                }
                return error
            }.result.get()
    }
}
