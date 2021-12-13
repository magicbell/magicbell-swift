//
//  UpdateUserPreferencesInteractor.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Harmony

struct UpdateUserPreferencesInteractor {

    private let executor: Executor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let updateUserPreferencesInteractor: Interactor.PutByQuery<UserPreferences>

    init(
        executor: Executor,
        getUserQueryInteractor: GetUserQueryInteractor,
        updateUserPreferencesInteractor: Interactor.PutByQuery<UserPreferences>
    ) {
        self.executor = executor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.updateUserPreferencesInteractor = updateUserPreferencesInteractor
    }

    func execute(_ userPreferences: UserPreferences) -> Future<UserPreferences> {
        return executor.submit { resolver in
            let userQuery = try getUserQueryInteractor.execute()
            resolver.set(updateUserPreferencesInteractor.execute(userPreferences, query: userQuery, in: DirectExecutor()))
        }
    }
}
