//
//  UserPreferencesProvider.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

public protocol UserPreferencesComponent {
    func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences>
    func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences>
}

class DefaultUserPreferencesModule: UserPreferencesComponent {
    private let httpClient: HttpClient

    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    private lazy var userPreferencesNetworkDatasource = UserPreferencesNetworkDataSource(
        httpClient: httpClient,
        mapper: DataToDecodableMapper<UserPreferences>()
    )

    func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences> {
        AnyGetDataSource(userPreferencesNetworkDatasource)
    }

    func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences> {
        AnyPutDataSource(userPreferencesNetworkDatasource)
    }
}
