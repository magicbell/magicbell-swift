//
//  NotificationNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

class NotificationNetworkDataSource: GetDataSource {
    typealias T = Notification

    private let httpClient: HttpClient
    private let mapper: DataToDecodableMapper<Notification>

    init(
        httpClient: HttpClient,
        mapper: DataToDecodableMapper<Notification>
    ) {
        self.httpClient = httpClient
        self.mapper = mapper
    }
    
    func get(_ query: Query) -> Future<Notification> {
        switch query {
        case let notificationQuery as NotificationQuery:
            let urlRequest = self.httpClient.prepareURLRequest(
                path: "/notifications/\(notificationQuery.notificationId)",
                externalId: notificationQuery.user.externalId,
                email: notificationQuery.user.email
            )
            return self.httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }

    func getAll(_ query: Query) -> Future<[Notification]> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
}
