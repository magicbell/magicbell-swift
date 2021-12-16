//
//  GetUserConfigInteractor.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

struct GetConfigInteractor {
    private let getConfigInteractor: Interactor.GetByQuery<Config>

    init(_ getConfigInteractor: Interactor.GetByQuery<Config>) {
        self.getConfigInteractor = getConfigInteractor
    }

    func execute(forceRefresh: Bool, userQuery: UserQuery) -> Future<Config> {
        let operation: Harmony.Operation = forceRefresh ? MainSyncOperation() : CacheSyncOperation(fallback: true)
        return getConfigInteractor.execute(userQuery, operation)
    }
}
