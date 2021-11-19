//
//  PushSubscriptionProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

protocol PushSubscriptionComponent {
    func getPushSubscriptionNetworkDataSource() -> AnyPutDataSource<PushSubscription>
    func getDeletePushSubscriptionNetworkDataSource() -> DeleteDataSource
}

class DefaultPushSubscriptionModule: PushSubscriptionComponent {
    private let environment: Environment
    private let httpClient: HttpClient

    init(environment: Environment, httpClient: HttpClient) {
        self.environment = environment
        self.httpClient = httpClient
    }

    private lazy var pushSubscriptionNetworkDataSource = PushSubscriptionNetworkDataSource(
            environment: environment,
            httpClient: httpClient,
            mapper: DataToDecodableMapper<PushSubscription>()
    )

    func getPushSubscriptionNetworkDataSource() -> AnyPutDataSource<PushSubscription> {
        AnyPutDataSource(pushSubscriptionNetworkDataSource)
    }

    func getDeletePushSubscriptionNetworkDataSource() -> DeleteDataSource {
        pushSubscriptionNetworkDataSource
    }
}
