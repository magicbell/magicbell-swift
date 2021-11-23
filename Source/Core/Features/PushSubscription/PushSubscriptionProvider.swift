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

class DefaultPushSubscriptionModule: PushSubscriptionComponent {
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    private lazy var pushSubscriptionNetworkDataSource = PushSubscriptionNetworkDataSource(
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
