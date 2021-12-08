//
//  StoreDeviceTokenInteractor.swift
//  MagicBell
//
//  Created by Javi on 8/12/21.
//

import Harmony


struct StoreDeviceTokenInteractor {
    private let storeDeviceTokenInteractor: Interactor.PutByQuery<String>

    init(storeDeviceTokenInteractor: Interactor.PutByQuery<String>) {
        self.storeDeviceTokenInteractor = storeDeviceTokenInteractor
    }

    func execute(deviceToken: String) -> Future<String> {
        return storeDeviceTokenInteractor.execute(deviceToken, query: DeviceTokenQuery(), in: DirectExecutor())
    }
}
