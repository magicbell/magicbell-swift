//
//  AblyProvider.swift
//  MagicBell
//
//  Created by Javi on 3/12/21.
//

import Harmony

protocol StoreRealTimeComponent {
    func createStoreRealmTime(userQuery: UserQuery) -> StoreRealTime
}

class DefaultStoreRealTimeModule: StoreRealTimeComponent {
    private let configComponent: ConfigComponent
    private let environment: Environment
    private let logger: Logger

    init(configComponent: ConfigComponent,
         environment: Environment,
         logger: Logger) {
        self.configComponent = configComponent
        self.environment = environment
        self.logger = logger
    }

    func createStoreRealmTime(userQuery: UserQuery) -> StoreRealTime {
        return AblyConnector(
            getConfigInteractor: configComponent.getGetConfigInteractor(),
            userQuery: userQuery,
            environment: environment,
            logger: logger
        )
    }
}
