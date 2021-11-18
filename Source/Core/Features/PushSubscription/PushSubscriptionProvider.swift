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
    private let urlSession: URLSession

    init(environment: Environment, urlSession: URLSession) {
        self.environment = environment
        self.urlSession = urlSession
    }

    private lazy var pushSubscriptionNetworkDataSource = PushSubscriptionNetworkDataSource(
            environment: environment,
            urlSession: urlSession,
            mapper: DataToDecodableMapper<PushSubscription>()
    )

    func getPushSubscriptionNetworkDataSource() -> AnyPutDataSource<PushSubscription> {
        AnyPutDataSource(pushSubscriptionNetworkDataSource)
    }

    func getDeletePushSubscriptionNetworkDataSource() -> DeleteDataSource {
        pushSubscriptionNetworkDataSource
    }
}
