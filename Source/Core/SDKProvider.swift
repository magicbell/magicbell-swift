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

    // TODO: make it private once not required for development
    public lazy var executorComponent: ExecutorComponent = DefaultExecutorModule()
    private lazy var configComponent: ConfigComponent = DefaultConfigModule(
        httpClient: httpClient,
        executor: executorComponent.mainExecutor
    )
    public lazy var userPreferencesComponent: UserPreferencesComponent = DefaultUserPreferencesModule(httpClient: httpClient)
    public lazy var notificationComponent: NotificationComponent = DefaultNotificationComponent(httpClient: httpClient)
    public lazy var pushSubscriptionComponent: PushSubscriptionComponent = DefaultPushSubscriptionModule(httpClient: httpClient)
    private lazy var userComponent: UserComponent = DefaultUserComponent(
        logger: logger,
        configComponent: configComponent,
        executor: executorComponent.mainExecutor
    )

    // MARK: SDKComponent
    func getLogger() -> Logger {
        return logger
    }

    func getUserComponent() -> UserComponent {
        return userComponent
    }
}

public protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    public lazy var mainExecutor = DispatchQueueExecutor()
}
