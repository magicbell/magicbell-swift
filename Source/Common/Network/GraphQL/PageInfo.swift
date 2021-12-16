//
//  PageInfo.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

struct PageInfo: Codable {
    let endCursor: String?
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    let startCursor: String?
}
