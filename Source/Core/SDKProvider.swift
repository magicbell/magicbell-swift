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
    func createStore(name: String?, predicate: StorePredicate) throws -> NotificationStore
    func getStoreDeviceTokenInteractor() -> StoreDeviceTokenInteractor
}

// TODO: Remove public
public class DefaultSDKModule: SDKComponent {
    private let environment: Environment
    private let logger: Logger

    init(environment: Environment, logger: Logger) {
        self.environment = environment
        self.logger = logger
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

    // TODO: Remove public and make it private
    public lazy var userPreferencesComponent: UserPreferencesComponent = DefaultUserPreferencesModule(httpClient: httpClient)
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

    func getStoreDeviceTokenInteractor() -> StoreDeviceTokenInteractor {
        return pushSubscriptionComponent.getStoreDeviceTokenInteractor()
    }
}

public protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    public lazy var mainExecutor = DispatchQueueExecutor()
}
