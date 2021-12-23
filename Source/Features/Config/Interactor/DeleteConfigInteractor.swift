//
//  DeleteUserConfigInteractor.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

protocol DeleteConfigInteractor {
    func execute() -> Future<Void>
}

struct DeleteConfigDefaultInteractor: DeleteConfigInteractor {
    private let deleteConfigInteractor: Interactor.DeleteAllByQuery

    init(_ deleteConfigInteractor: Interactor.DeleteAllByQuery) {
        self.deleteConfigInteractor = deleteConfigInteractor
    }

    func execute() -> Future<Void> {
        return deleteConfigInteractor.execute(AllObjectsQuery(), CacheOperation())
    }
}
