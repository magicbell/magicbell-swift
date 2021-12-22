//
//  ActionNotificationMockInteractor.swift
//  MagicBellTests
//
//  Created by Javi on 20/12/21.
//

@testable import MagicBell
@testable import Harmony

class ActionNotificationMockInteractor: ActionNotificationInteractor {

    private let expectedResult: Result<Void, Error>

    init(expectedResult: Result<Void, Error> = .success(())) {
        self.expectedResult = expectedResult
    }

    private(set) var executeParamsSpy: [MethodParams.Execute] = []
    var executeCounter: Int {
        executeParamsSpy.count
    }

    func execute(action: NotificationActionQuery.Action, userQuery: UserQuery, notificationId: String?) -> Future<Void> {
        executeParamsSpy.append(MethodParams.Execute(action: action, userQuery: userQuery, notificationId: notificationId))
        return TestUtils.result(expectedResult: expectedResult)
    }

    class MethodParams {
        struct Execute {
            let action: NotificationActionQuery.Action
            let userQuery: UserQuery
            let notificationId: String?
        }
    }
}
