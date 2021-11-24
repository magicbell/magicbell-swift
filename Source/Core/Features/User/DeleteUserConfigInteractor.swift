//
//  DeleteUserConfigInteractor.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

public struct DeleteUserConfigInteractor {
    private let deleteUserConfigInteractor: Interactor.DeleteAllByQuery

    public init(_ deleteUserConfigInteractor: Interactor.DeleteAllByQuery) {
        self.deleteUserConfigInteractor = deleteUserConfigInteractor
    }

    public func execute(userQuery: UserQuery) -> Future<Void> {
        return deleteUserConfigInteractor.execute(AllObjectsQuery(), CacheOperation())
    }
}
