//
//  StoreDeviceTokenInteractor.swift
//  MagicBell
//
//  Created by Javi on 8/12/21.
//

import Harmony

struct SaveDeviceTokenInteractor {
    private let saveDeviceTokenInteractor: Interactor.PutByQuery<String>

    init(saveDeviceTokenInteractor: Interactor.PutByQuery<String>) {
        self.saveDeviceTokenInteractor = saveDeviceTokenInteractor
    }

    func execute(deviceToken: Data) -> Future<String> {
        let deviceTokenString = String(data: deviceToken, encoding: .utf8)
        return saveDeviceTokenInteractor.execute(deviceTokenString, query: DeviceTokenQuery(), in: DirectExecutor())
    }
}
