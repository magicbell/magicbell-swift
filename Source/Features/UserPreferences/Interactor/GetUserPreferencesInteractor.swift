//
//  GetUserPreferencesInteractor.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Harmony

struct GetUserPreferencesInteractor {
    private let executor: Executor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let getUserPreferencesInteractor: Interactor.GetByQuery<UserPreferences>

    init(
        executor: Executor,
        getUserQueryInteractor: GetUserQueryInteractor,
        getUserPreferencesInteractor: Interactor.GetByQuery<UserPreferences>
    ) {
        self.executor = executor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.getUserPreferencesInteractor = getUserPreferencesInteractor
    }

    func execute() -> Future<UserPreferences> {
        return executor.submit { resolver in
            let userQuery = try getUserQueryInteractor.execute()
            resolver.set(getUserPreferencesInteractor.execute(userQuery, in: DirectExecutor()))
        }
    }
}
