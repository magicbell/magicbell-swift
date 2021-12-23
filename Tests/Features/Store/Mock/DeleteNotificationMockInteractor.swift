//
//  DeleteNotificationMockInteractor.swift
//  MagicBellTests
//
//  Created by Javi on 20/12/21.
//

@testable import MagicBell
@testable import Harmony

class DeleteNotificationMockInteractor: DeleteNotificationInteractor {

    private let expectedResult: Result<Void, Error>

    init(expectedResult: Result<Void, Error> = .success(())) {
        self.expectedResult = expectedResult
    }

    private(set) var executeParamsSpy: [MethodParams.Execute] = []
    var executeCounter: Int {
        executeParamsSpy.count
    }

    func execute(notificationId: String, userQuery: UserQuery) -> Future<Void> {
        executeParamsSpy.append(MethodParams.Execute(notificationId: notificationId, userQuery: userQuery))
        return TestUtils.result(expectedResult: expectedResult)
    }

    class MethodParams {

        struct Execute {
            let notificationId: String
            let userQuery: UserQuery
        }
    }
}
