//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
//

import Foundation
import Harmony

protocol SDKComponent {
    func getLogger() -> Logger
    func getStoreComponent() -> StoreComponent
    func getStoreRealTimeComponent() -> StoreRealTimeComponent
    func getPushSubscriptionComponent() -> PushSubscriptionComponent
    func getNotificationPreferencesComponent() -> NotificationPreferencesComponent
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
    private lazy var notificationPreferencesComponent = DefaultNotificationPreferencesModule(
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

    func getNotificationPreferencesComponent() -> NotificationPreferencesComponent {
        return notificationPreferencesComponent
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
