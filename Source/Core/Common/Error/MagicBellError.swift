//
//  MagicBellError.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation

class MagicBellError: LocalizedError, CustomStringConvertible {
    var errorDescription: String?

    public init(_ errorMessage: String) {
        errorDescription = errorMessage
    }

    var description: String {
        return errorDescription ?? "MagicBellError"
    }
}
