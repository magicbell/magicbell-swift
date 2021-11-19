//
//  UserPreferencesProvider.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

protocol UserPreferencesComponent {
    func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences>
    func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences>
}

class DefaultUserPreferencesModule: UserPreferencesComponent {

    private let environment: Environment
    private let httpClient: HttpClient

    init(environment: Environment,
         httpClient: HttpClient) {
        self.environment = environment
        self.httpClient = httpClient
    }

    private lazy var userPreferencesNetworkDatasource = UserPreferencesNetworkDataSource(
            environment: environment,
            httpClient: httpClient,
            mapper: DataToDecodableMapper<UserPreferences>())


    func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences> {
        AnyGetDataSource(userPreferencesNetworkDatasource)
    }

    func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences> {
        AnyPutDataSource(userPreferencesNetworkDatasource)
    }
}
