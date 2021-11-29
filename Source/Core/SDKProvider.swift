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
    func createNotificationStore(name: String, predicate: StorePredicate) throws -> NotificationStore
    func getNotificationStore(name: String) -> NotificationStore?
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
    private lazy var userComponent: UserComponent = DefaultUserComponent(
        logger: logger,
        configComponent: configComponent,
        executor: executorComponent.mainExecutor
    )
    private lazy var notificationStoreComponent: NotificationStoreComponent = DefaultNotificationStoreModule(storeComponent: storeComponent,
                                                                                                             userComponent: userComponent,
                                                                                                             logger: logger)

    // TODO: Remove public and make it private
    public lazy var userPreferencesComponent: UserPreferencesComponent = DefaultUserPreferencesModule(httpClient: httpClient)
    public lazy var notificationComponent: NotificationComponent = DefaultNotificationComponent(httpClient: httpClient)
    public lazy var pushSubscriptionComponent: PushSubscriptionComponent = DefaultPushSubscriptionModule(httpClient: httpClient)
    public lazy var storeComponent: StoreComponent = DefaultStoreModule(httpClient: httpClient, executor: executorComponent.mainExecutor)


    // MARK: SDKComponent
    func getLogger() -> Logger {
        return logger
    }

    func getUserComponent() -> UserComponent {
        return userComponent
    }

    func createNotificationStore(name: String, predicate: StorePredicate) throws -> NotificationStore {
        return try notificationStoreComponent.notificationStoreCoordinator.createNotificationStore(name: name, storePredicate: predicate)
    }

    func getNotificationStore(name: String) -> NotificationStore? {
        return notificationStoreComponent.notificationStoreCoordinator.getNotificationStore(name: name)
    }
}

public protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    public lazy var mainExecutor = DispatchQueueExecutor()
}
