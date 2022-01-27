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

@testable import MagicBell
import Harmony

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
