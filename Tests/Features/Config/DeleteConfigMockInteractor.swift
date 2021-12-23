//
//  DeleteConfigMockInteractor.swift
//  MagicBellTests
//
//  Created by Javi on 20/12/21.
//

@testable import Harmony
@testable import MagicBell

class DeleteConfigMockInteractor: DeleteConfigInteractor {

    private let expectedResult: Result<Void, Error>

    init(expectedResult: Result<Void, Error>) {
        self.expectedResult = expectedResult
    }

    private(set) var executeParamsSpy: [MethodParams.Execute] = []
    var executeCounter: Int {
        executeParamsSpy.count
    }

    func execute() -> Future<Void> {
        executeParamsSpy.append(MethodParams.Execute())
        return TestUtils.result(expectedResult: expectedResult)
    }

    class MethodParams {
        struct Execute {
        }
    }
}
