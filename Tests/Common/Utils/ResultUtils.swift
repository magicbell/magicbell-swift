//
//  ResultUtils.swift
//  MagicBell
//
//  Created by Javi on 28/1/22.
//

import Foundation
import Harmony

enum TestUtils<T> {
    static func result(expectedResult: Result<T, Error>) -> Future<T> {
        switch expectedResult {
        case .success(let value):
            return Future(value)
        case .failure(let error):
            return Future(error)
        }
    }
}
