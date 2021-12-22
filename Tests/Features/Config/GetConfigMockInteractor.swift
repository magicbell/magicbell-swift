//
//  GetConfigMockInteractor.swift
//  MagicBellTests
//
//  Created by Javi on 20/12/21.
//

@testable import Harmony
@testable import MagicBell

class GetConfigMockInteractor: GetConfigInteractor {

    private let expectedResult: Result<Config, Error>

    init(expectedResult: Result<Config, Error>) {
        self.expectedResult = expectedResult
    }

    private(set) var executeParamsSpy: [MethodParams.Execute] = []
    var executeCounter: Int {
        executeParamsSpy.count
    }

    func execute(forceRefresh: Bool, userQuery: UserQuery) -> Future<Config> {
        executeParamsSpy.append(MethodParams.Execute(forceRefresh: forceRefresh, userQuery: userQuery))
        return TestUtils.result(expectedResult: expectedResult)
    }

    class MethodParams {
        struct Execute {
            let forceRefresh: Bool
            let userQuery: UserQuery
        }
    }
}
