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

import Harmony

class ActionNotificationNetworkDataSource: PutDataSource, DeleteDataSource {
    typealias T = Void
    
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func put(_ value: Void?, in query: Query) -> Future<Void> {
        switch query {
        case let notificationActionQuery as NotificationActionQuery:
            var path = "/notifications"
            var httpMethod = "POST"
            switch notificationActionQuery.action {
            case .markAsRead:
                path.append("/\(notificationActionQuery.notificationId)/read")
            case .markAsUnread:
                path.append("/\(notificationActionQuery.notificationId)/unread")
            case .unarchive:
                path.append("/\(notificationActionQuery.notificationId)/archive")
                httpMethod = "DELETE"
            case .archive:
                path.append("/\(notificationActionQuery.notificationId)/archive")
            case .markAllAsRead:
                path.append("/read")
            case .markAllAsSeen:
                path.append("/seen")
            }
            
            var urlRequest = self.httpClient.prepareURLRequest(
                path: path,
                externalId: notificationActionQuery.user.externalId,
                email: notificationActionQuery.user.email,
                hmac: notificationActionQuery.user.hmac
            )
            
            urlRequest.httpMethod = httpMethod
            
            return self.httpClient
                .performRequest(urlRequest)
                .map { _ in Void() }
        default:
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }
    
    func putAll(_ array: [Void], in query: Query) -> Future<[Void]> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
    
    func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let notificationQuery as NotificationQuery:
            var urlRequest = self.httpClient.prepareURLRequest(
                path: "/notifications/\(notificationQuery.notificationId)",
                externalId: notificationQuery.user.externalId,
                email: notificationQuery.user.email,
                hmac: notificationQuery.user.hmac
            )
            urlRequest.httpMethod = "DELETE"
            
            return self.httpClient
                .performRequest(urlRequest)
                .map { _ in Void() }
        default:
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }
    
    func deleteAll(_ query: Query) -> Future<Void> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
}
