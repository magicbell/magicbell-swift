//
//  MappingError.swift
//  MagicBell
//
//  Created by Javi on 19/11/21.
//

import Foundation

class MappingError: LocalizedError {
    var errorDescription: String? {
        return "There was an error while mapping \(className)"
    }

    private let className: String
    init(className: String) {
        self.className = className
    }
}
