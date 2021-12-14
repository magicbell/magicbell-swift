//
//  UpdateUserPreferencesInteractor.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Harmony

struct UpdateUserPreferencesInteractor {

    private let executor: Executor
    private let updateUserPreferencesInteractor: Interactor.PutByQuery<UserPreferences>

    init(
        executor: Executor,
        updateUserPreferencesInteractor: Interactor.PutByQuery<UserPreferences>
    ) {
        self.executor = executor
        self.updateUserPreferencesInteractor = updateUserPreferencesInteractor
    }

    func execute(_ userPreferences: UserPreferences, userQuery: UserQuery) -> Future<UserPreferences> {
        return executor.submit { resolver in
            resolver.set(updateUserPreferencesInteractor.execute(userPreferences, query: userQuery, in: DirectExecutor()))
        }
    }
}
