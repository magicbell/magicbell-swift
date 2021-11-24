//
//  GetUserConfigInteractor.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

public struct GetUserConfigInteractor {
    private let getUserConfigInteractor: Interactor.GetByQuery<Config>

    public init(_ getUserConfigInteractor: Interactor.GetByQuery<Config>) {
        self.getUserConfigInteractor = getUserConfigInteractor
    }

    public func execute(refresh: Bool, userQuery: UserQuery) -> Future<Config> {
        return getUserConfigInteractor.execute(userQuery, refresh ? CacheSyncOperation(fallback: true) : CacheOperation())
    }
}
