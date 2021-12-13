//
//  MappingError.swift
//  MagicBell
//
//  Created by Javi on 19/11/21.
//

import Foundation

public class MappingError: LocalizedError {
    public var errorDescription: String? {
            return "There was an error while mapping \(className)"
    }

    private let className: String

    public init(className: String) {
        self.className = className
    }
}
