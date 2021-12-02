//
//  Edge.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

public struct Edge<T: Codable>: Codable {

    public let cursor: String
    public var node: T

    enum CodingKeys: String, CodingKey {
        case cursor
        case node
    }
}
