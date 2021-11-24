//
//  GetUserConfigInteractor.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

struct GetUserConfigInteractor {
    private let getUserConfigInteractor: Interactor.GetByQuery<Config>

    public init(_ getUserConfigInteractor: Interactor.GetByQuery<Config>) {
        self.getUserConfigInteractor = getUserConfigInteractor
    }

    public func execute(forceRefresh: Bool, userQuery: UserQuery) -> Future<Config> {
        let operation: Harmony.Operation = forceRefresh ? MainSyncOperation() : CacheSyncOperation(fallback: true)
        return getUserConfigInteractor.execute(userQuery, operation)
    }
}
