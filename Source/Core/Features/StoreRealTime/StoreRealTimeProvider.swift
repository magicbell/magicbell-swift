//
//  AblyProvider.swift
//  MagicBell
//
//  Created by Javi on 3/12/21.
//

import Harmony

protocol StoreRealTimeComponent {
    func getStoreRealmTime() -> StoreRealTime
}

class DefaultStoreRealTimeModule: StoreRealTimeComponent {
    private let configComponent: ConfigComponent
    private let userQueryComponent: UserQueryComponent
    private let environment: Environment
    private let logger: Logger

    init(configComponent: ConfigComponent,
         userQueryComponent: UserQueryComponent,
         environment: Environment,
         logger: Logger) {
        self.configComponent = configComponent
        self.userQueryComponent = userQueryComponent
        self.environment = environment
        self.logger = logger
    }

    func getStoreRealmTime() -> StoreRealTime {
        return ablyConnector
    }

    private lazy var ablyConnector: AblyConnector = {
        return AblyConnector(
            getConfigInteractor: configComponent.getGetConfigInteractor(),
            userQueryInteractor: userQueryComponent.getUserQueryInteractor(),
            environment: environment,
            logger: logger
        )
    }()
}
