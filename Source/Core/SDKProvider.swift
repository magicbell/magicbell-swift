//
//  SDKProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

// TODO: remove public
public protocol SDKComponent {
    // TOOD: Do functions
}

// TODO: Remove public
public class DefaultSDKModule: SDKComponent {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    private lazy var httpClient: HttpClient = DefaultHttpClient(
        urlSession: URLSession.shared,
        environment: environment
    )

    // TODO: make it private once not required for development
    public lazy var executorComponent: ExecutorComponent = DefaultExecutorModule()
    private lazy var configComponent: ConfigComponent = DefaultConfigModule(httpClient: httpClient)
    public lazy var userPreferencesComponent: UserPreferencesComponent = DefaultUserPreferencesModule(httpClient: httpClient)
    public lazy var notificationComponent: NotificationComponent = DefaultNotificationComponent(httpClient: httpClient)
    public lazy var pushSubscriptionComponent: PushSubscriptionComponent = DefaultPushSubscriptionModule(httpClient: httpClient)
    public lazy var userConfigComponent: UserComponent = DefaultUserComponent(configComponent: configComponent, executor: executorComponent.mainExecutor)
    public lazy var storeComponent: StoreComponent = DefaultStoreModule(httpClient: httpClient, executor: executorComponent.mainExecutor)
}

public protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    public lazy var mainExecutor = DispatchQueueExecutor()
}
