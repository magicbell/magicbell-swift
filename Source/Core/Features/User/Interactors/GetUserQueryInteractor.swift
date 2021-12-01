//
//  GetUserQueryInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct GetUserQueryInteractor {
    private let getUserQueryInteractor: Interactor.GetByQuery<UserQuery>

    init(getUserQuery: Interactor.GetByQuery<UserQuery>) {
        self.getUserQueryInteractor = getUserQuery
    }

    /// This methods returns the user query with the user credentials or throws an error if user is not authenticated yet.
    func execute() -> Future<UserQuery> {
        getUserQueryInteractor.execute(IdQuery("userQuery"), in: DirectExecutor()).mapError { error in
            if error is CoreError.NotFound {
                return MagicBellError("Can't perform action because user is not identified. Please, call MagicBell.login to identify a user.")
            }
            return error
        }
    }

    /// This methods returns the user query with the user credentials or throws an error if user is not authenticated yet.
    func executeSync() throws -> UserQuery {
        try execute().result.get()
    }
}
