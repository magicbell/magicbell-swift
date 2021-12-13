//
//  SDKProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

// TODO: remove public
protocol SDKComponent {
    func getLogger() -> Logger
    func getUserComponent() -> UserComponent
    func createStore(name: String?, predicate: StorePredicate) -> NotificationStore
    func getSendPushSubscriptionInteractor() -> SendPushSubscriptionInteractor
    func getUserPreferencesInteractor() -> GetUserPreferencesInteractor
    func updateUserPreferencesInteractor() -> UpdateUserPreferencesInteractor
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
    private lazy var executorComponent: ExecutorComponent = DefaultExecutorModule()
    private lazy var configComponent: ConfigComponent = DefaultConfigModule(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor
    )

    private lazy var userQueryComponent: UserQueryComponent = DefaultUserQueryModule(
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

    private lazy var userPreferencesComponent: UserPreferencesComponent = DefaultUserPreferencesModule(httpClient: httpClient,
                                                                                                      executor: executorComponent.mainExecutor,
                                                                                                      userQueryComponent: userQueryComponent)
    private lazy var notificationComponent: NotificationComponent = DefaultNotificationComponent(httpClient: httpClient,
                                                                                                 executor: executorComponent.mainExecutor,
                                                                                                 userQueryComponent: userQueryComponent)
    private lazy var pushSubscriptionComponent: PushSubscriptionComponent = DefaultPushSubscriptionModule(userQueryComponent: userQueryComponent,
                                                                                                          httpClient: httpClient,
                                                                                                          executor: executorComponent.mainExecutor,
                                                                                                          logger: logger)
    private lazy var storeComponent: StoreComponent = DefaultStoreModule(httpClient: httpClient,
                                                                         executor: executorComponent.mainExecutor,
                                                                         userQueryComponent: userQueryComponent,
                                                                         notificationComponent: notificationComponent,
                                                                         storeRealTimeComponent: storeRealTimeComponent,
                                                                         logger: logger)
    private lazy var storeRealTimeComponent: StoreRealTimeComponent = DefaultStoreRealTimeModule(configComponent: configComponent,
                                                                                                 userQueryComponent: userQueryComponent,
                                                                                                 environment: environment,
                                                                                                 logger: logger)
    

    // MARK: SDKComponent
    func getLogger() -> Logger {
        return logger
    }

    func getUserComponent() -> UserComponent {
        return userComponent
    }

    func createStore(name: String?, predicate: StorePredicate) -> NotificationStore {
        return storeComponent.createStore(name: name, predicate: predicate)
    }

    func getSendPushSubscriptionInteractor() -> SendPushSubscriptionInteractor {
        return pushSubscriptionComponent.getSendPushSubscriptionInteractor()
    }

    func getUserPreferencesInteractor() -> GetUserPreferencesInteractor {
        return userPreferencesComponent.getGetUserPreferencesInteractor()
    }

    func updateUserPreferencesInteractor() -> UpdateUserPreferencesInteractor {
        return userPreferencesComponent.getUpdateUserPreferencesInteractor()
    }
}

public protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    public lazy var mainExecutor = DispatchQueueExecutor()
}
