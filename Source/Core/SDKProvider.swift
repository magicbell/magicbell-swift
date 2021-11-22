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
    public lazy var configComponent = DefaultConfigModule(httpClient: httpClient)
    public lazy var userPreferencesComponent = DefaultUserPreferencesModule(httpClient: httpClient)
    public lazy var notificationComponent = DefaultNotificationComponent(httpClient: httpClient)
    public lazy var pushSubscriptionComponent = DefaultPushSubscriptionModule(httpClient: httpClient)
}

public protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

public class DefaultExecutorModule: ExecutorComponent {
    public lazy var mainExecutor = DispatchQueueExecutor()
}
