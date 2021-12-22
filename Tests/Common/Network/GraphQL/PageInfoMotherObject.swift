//
//  PageInfoMotherObject.swift
//  MagicBell
//
//  Created by Javi on 20/12/21.
//

@testable import MagicBell
@testable import Harmony

func anyPageInfo() -> PageInfo {
    return PageInfo(
        endCursor: AnyCursor.any.rawValue,
        hasNextPage: randomBool(),
        hasPreviousPage: randomBool(),
        startCursor: AnyCursor.any.rawValue
    )
}

extension PageInfo {
    static func create(
        endCursor: String? = nil,
        hasNextPage: Bool = randomBool(),
        hasPreviousPage: Bool = randomBool(),
        startCursor: String? = nil
    ) -> PageInfo {
        return PageInfo(
            endCursor: endCursor,
            hasNextPage: hasNextPage,
            hasPreviousPage: hasPreviousPage,
            startCursor: startCursor
        )
    }
}
