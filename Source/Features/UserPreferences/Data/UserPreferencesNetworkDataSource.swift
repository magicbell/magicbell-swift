//
//  UserPreferencesNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

public class UserPreferencesNetworkDataSource: GetDataSource, PutDataSource {

    public typealias T = UserPreferencesEntity

    private let httpClient: HttpClient
    private let mapper: Mapper<Data, UserPreferencesEntity>

    public init(httpClient: HttpClient, mapper: Mapper<Data, UserPreferencesEntity>) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    public func get(_ query: Query) -> Future<UserPreferencesEntity> {
        switch query {
        case let userQuery as UserQuery:
            let urlRequest = self.httpClient.prepareURLRequest(
                path: "/notification_preferences",
                externalId: userQuery.externalId,
                email: userQuery.email
            )
            return self.httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[UserPreferencesEntity]> {
        query.fatalError(.getAll, self)
    }

    public func put(_ value: UserPreferencesEntity?, in query: Query) -> Future<UserPreferencesEntity> {
        switch query {
        case let userQuery as UserQuery:
            guard let value = value else {
                return Future(CoreError.NotValid())
            }

            var urlRequest = self.httpClient.prepareURLRequest(
                path: "/notification_preferences",
                externalId: userQuery.externalId,
                email: userQuery.email
            )
            urlRequest.httpMethod = "PUT"

            do {
                urlRequest.httpBody = try JSONEncoder().encode(value)
            } catch {
                return Future(MappingError(className: "\(T.self)"))
            }
            return self.httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            query.fatalError(.get, self)
        }
    }

    public func putAll(_ array: [UserPreferencesEntity], in query: Query) -> Future<[UserPreferencesEntity]> {
        query.fatalError(.putAll, self)
    }
}
