//
//  SDKProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

protocol SDKComponent {
    // TOOD: Do functions
    func getConfigDataSource() -> AnyGetDataSource<Config>
    func getUserPreferencesDataSource() -> AnyGetDataSource<UserPreferences>
    func getPutUserPreferencesDataSource() -> AnyPutDataSource<UserPreferences>
    func getNotificationDataSource() -> AnyGetDataSource<Notification>
    func getActionNotificationDataSource() -> AnyPutDataSource<Void>
    func getDeleteNotificationDataSource() -> DeleteDataSource
    func getPushSubscriptionDataSource() -> AnyPutDataSource<PushSubscription>
    func getDeletePushSubscriptionDataSource() -> DeleteDataSource
}

class DefaultSDKModule: SDKComponent {
    private let environment: Environment
    // TODO: Move it later if we do a custom one.
    lazy var httpClient = HttpClient(urlSession: URLSession.shared)

    private lazy var executorComponent: ExecutorComponent = DefaultExecutorModule()
    private lazy var configComponent = DefaultConfigModule(environment: environment, httpClient: httpClient)
    private lazy var userPreferencesComponent = DefaultUserPreferencesModule(environment: environment, httpClient: httpClient)
    private lazy var notificationComponent = DefaultNotificationComponent(environment: environment, httpClient: httpClient)
    private lazy var pushSubscriptionComponent = DefaultPushSubscriptionModule(environment: environment, httpClient: httpClient)

    init(environment: Environment) {
        self.environment = environment
    }

    private lazy var configDataSource: AnyGetDataSource<Config> = configComponent.getConfigNetworkDataSource()

    func getConfigDataSource() -> AnyGetDataSource<Config> {
        configDataSource
    }

    private lazy var userPreferencesDataSource: AnyGetDataSource<UserPreferences> = userPreferencesComponent.getUserPreferencesNetworkDataSource()

    func getUserPreferencesDataSource() -> AnyGetDataSource<UserPreferences> {
        userPreferencesDataSource
    }

    private lazy var putUserPreferencesDataSource: AnyPutDataSource<UserPreferences> = userPreferencesComponent.getPutUserPreferenceNetworkDataSource()

    func getPutUserPreferencesDataSource() -> AnyPutDataSource<UserPreferences> {
        putUserPreferencesDataSource
    }

    private lazy var notificationDataSource: AnyGetDataSource<Notification> = notificationComponent.getNotificationNetworkDataSource()

    func getNotificationDataSource() -> AnyGetDataSource<Notification> {
        notificationDataSource
    }

    private lazy var actionNotificationDataSource: AnyPutDataSource<Void> = notificationComponent.getActionNotificationNetworkDataSource()

    func getActionNotificationDataSource() -> AnyPutDataSource<Void> {
        actionNotificationDataSource
    }

    private lazy var deleteNotificationDataSource: DeleteDataSource = notificationComponent.getDeleteNotificationNetworkDataSource()

    func getDeleteNotificationDataSource() -> DeleteDataSource {
        deleteNotificationDataSource
    }

    private lazy var pushSubscriptionDataSource: AnyPutDataSource<PushSubscription> = pushSubscriptionComponent.getPushSubscriptionNetworkDataSource()

    func getPushSubscriptionDataSource() -> AnyPutDataSource<PushSubscription> {
        pushSubscriptionDataSource
    }

    private lazy var deletePushSubscriptionDataSource: DeleteDataSource = pushSubscriptionComponent.getDeletePushSubscriptionNetworkDataSource()

    func getDeletePushSubscriptionDataSource() -> DeleteDataSource {
        deletePushSubscriptionDataSource
    }
}

protocol ExecutorComponent {
    var mainExecutor: DispatchQueueExecutor { get }
}

class DefaultExecutorModule: ExecutorComponent {
    lazy var mainExecutor = DispatchQueueExecutor()
}
