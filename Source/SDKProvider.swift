//
//  SDKProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

protocol SDKComponent {
    func getLogger() -> Logger
    func getStoreComponent() -> StoreComponent
    func getStoreRealTimeComponent() -> StoreRealTimeComponent
    func getPushSubscriptionComponent() -> PushSubscriptionComponent
    func getUserPreferencesComponent() -> UserPreferencesComponent
    func getConfigComponent() -> ConfigComponent
}

class DefaultSDKModule: SDKComponent {
    private let environment: Environment
    private let logger: Logger

    init(environment: Environment,
         logLevel: LogLevel) {
        self.environment = environment
        self.logger = logLevel.obtainLogger()
    }

    private lazy var httpClient: HttpClient = DefaultHttpClient(
        urlSession: URLSession.shared,
        environment: environment
    )

    // Components

    private lazy var executorComponent: ExecutorComponent = DefaultExecutorModule()
    private lazy var configComponent: ConfigComponent = DefaultConfigModule(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor
    )
    private lazy var userPreferencesComponent = DefaultUserPreferencesModule(
        logger: logger,
        httpClient: httpClient,
        executor: executorComponent.mainExecutor
    )
    private lazy var notificationComponent = DefaultNotificationComponent(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor
    )
    private lazy var pushSubscriptionComponent = DefaultPushSubscriptionModule(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor,
        logger: logger
    )
    private lazy var storeComponent: StoreComponent = DefaultStoreModule(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor,
        notificationComponent: notificationComponent,
        storeRealTimeComponent: storeRealTimeComponent,
        configComponent: configComponent,
        logger: logger
    )
    private lazy var storeRealTimeComponent = DefaultStoreRealTimeModule(
        configComponent: configComponent,
        environment: environment,
        logger: logger
    )

    // MARK: SDKComponent

    func getLogger() -> Logger {
        return logger
    }

    func getStoreComponent() -> StoreComponent {
        return storeComponent
    }

    func getStoreRealTimeComponent() -> StoreRealTimeComponent {
        return storeRealTimeComponent
    }

    func getPushSubscriptionComponent() -> PushSubscriptionComponent {
        return pushSubscriptionComponent
    }

    func getUserPreferencesComponent() -> UserPreferencesComponent {
        return userPreferencesComponent
    }

    func getConfigComponent() -> ConfigComponent {
        return configComponent
    }
}

protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    lazy var mainExecutor = DispatchQueueExecutor()
}
