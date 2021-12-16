//
//  GetUserPreferencesInteractor.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Harmony

struct GetUserPreferencesInteractor {
    private let executor: Executor
    private let getUserPreferencesInteractor: Interactor.GetByQuery<UserPreferences>

    init(
        executor: Executor,
        getUserPreferencesInteractor: Interactor.GetByQuery<UserPreferences>
    ) {
        self.executor = executor
        self.getUserPreferencesInteractor = getUserPreferencesInteractor
    }

    func execute(userQuery: UserQuery) -> Future<UserPreferences> {
        return executor.submit { resolver in
            resolver.set(getUserPreferencesInteractor.execute(userQuery, in: DirectExecutor()))
        }
    }
}
