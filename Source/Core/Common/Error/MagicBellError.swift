//
//  MagicBellError.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation

class MagicBellError: LocalizedError {
    var errorDescription: String?

    public init(_ errorMessage: String) {
        errorDescription = errorMessage
    }
}
