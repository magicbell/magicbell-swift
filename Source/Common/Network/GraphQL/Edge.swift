//
//  Edge.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

struct Edge<T: Codable>: Codable {

    let cursor: String
    var node: T

    enum CodingKeys: String, CodingKey {
        case cursor
        case node
    }
}
