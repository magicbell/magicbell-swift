//
//  PushSubscriptionProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

public protocol PushSubscriptionComponent {
    func getPushSubscriptionNetworkDataSource() -> AnyPutDataSource<PushSubscription>
    func getDeletePushSubscriptionNetworkDataSource() -> DeleteDataSource
}

public class DefaultPushSubscriptionModule: PushSubscriptionComponent {
    private let httpClient: HttpClient

    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    private lazy var pushSubscriptionNetworkDataSource = PushSubscriptionNetworkDataSource(
            httpClient: httpClient,
            mapper: DataToDecodableMapper<PushSubscription>()
    )

    public func getPushSubscriptionNetworkDataSource() -> AnyPutDataSource<PushSubscription> {
        AnyPutDataSource(pushSubscriptionNetworkDataSource)
    }

    public func getDeletePushSubscriptionNetworkDataSource() -> DeleteDataSource {
        pushSubscriptionNetworkDataSource
    }
}
