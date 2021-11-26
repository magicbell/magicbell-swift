//
//  PageInfo.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

public struct PageInfo: Codable {
    public let endCursor: String?
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool
    public let startCursor: String?
}
