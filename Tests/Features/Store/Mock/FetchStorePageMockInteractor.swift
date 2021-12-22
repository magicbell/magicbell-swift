//
//  FetchStorePageMockInteractor.swift
//  MagicBell
//
//  Created by Javi on 20/12/21.
//

@testable import MagicBell
@testable import Harmony

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
