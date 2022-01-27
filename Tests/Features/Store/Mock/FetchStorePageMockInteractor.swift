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

class FetchStorePageMockInteractor: FetchStorePageInteractor {
    
    var expectedResult: Result<StorePage, Error>
    
    internal init(expectedResult: Result<StorePage, Error>) {
        self.expectedResult = expectedResult
    }

    private (set) var executeParamsSpy: [MethodParams.Execute] = []
    var executeCounter: Int {
        executeParamsSpy.count
    }
    
    func execute(storePredicate: StorePredicate, userQuery: UserQuery, cursorPredicate: CursorPredicate) -> Future<StorePage> {
        executeParamsSpy.append(MethodParams.Execute(storePredicate: storePredicate, userQuery: userQuery, cursorPredicate: cursorPredicate))
        return TestUtils.result(expectedResult: expectedResult)
    }
    
    class MethodParams {

        struct Execute {
            let storePredicate: StorePredicate
            let userQuery: UserQuery
            let cursorPredicate: CursorPredicate
        }
    }
}
