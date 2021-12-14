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
    func getUserComponent() -> UserComponent
    func getStoreComponent() -> StoreComponent
    func getStoreRealTimeComponent() -> StoreRealTimeComponent
    func getPushSubscriptionComponent() -> PushSubscriptionComponent
    func getUserPreferencesComponent() -> UserPreferencesComponent
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

    private lazy var userQueryComponent = DefaultUserQueryModule(
        executor: executorComponent.mainExecutor
    )
    private lazy var userComponent: UserComponent = DefaultUserComponent(
        logger: logger,
        configComponent: configComponent,
        userQueryComponent: userQueryComponent,
        storeRealTimeComponent: storeRealTimeComponent,
        pushSubscriptionComponent: pushSubscriptionComponent,
        executor: executorComponent.mainExecutor
    )
    private lazy var userPreferencesComponent = DefaultUserPreferencesModule(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor,
        userQueryComponent: userQueryComponent
    )
    private lazy var notificationComponent = DefaultNotificationComponent(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor
    )
    private lazy var pushSubscriptionComponent = DefaultPushSubscriptionModule(
        userQueryComponent: userQueryComponent,
        httpClient: httpClient,
        executor: executorComponent.mainExecutor,
        logger: logger
    )
    private lazy var storeComponent: StoreComponent = DefaultStoreModule(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor,
        userQueryComponent: userQueryComponent,
        notificationComponent: notificationComponent,
        storeRealTimeComponent: storeRealTimeComponent,
        logger: logger
    )
    private lazy var storeRealTimeComponent = DefaultStoreRealTimeModule(
        configComponent: configComponent,
        userQueryComponent: userQueryComponent,
        environment: environment,
        logger: logger
    )

    // MARK: SDKComponent

    func getLogger() -> Logger {
        return logger
    }

    func getUserComponent() -> UserComponent {
        return userComponent
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
}

public protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    lazy var mainExecutor = DispatchQueueExecutor()
}
