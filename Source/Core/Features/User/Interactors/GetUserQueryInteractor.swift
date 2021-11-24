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

    /// This methods returns the user query with the user credentials or throws an error if user is not authenticated yet.
    func execute() throws -> UserQuery {
        return try getUserQuery
            .execute(IdQuery("userQuery"), in: DirectExecutor())
            .mapError { error in
                if error is CoreError.NotFound {
                    // In this case, we want to throw an exception, as the user is attempting to perform an action without
                    // having identified previously a user by email or userId.
                    return MagicBellError("Can't perform action because user is not identified. Please, call MagicBell.login to identify a user.")
                }
                return error
            }.result.get()
    }
}
