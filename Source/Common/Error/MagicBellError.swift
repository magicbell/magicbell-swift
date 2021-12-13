//
//  MagicBellError.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation

public class MagicBellError: LocalizedError, CustomStringConvertible {
    public var errorDescription: String?

    public init(_ errorMessage: String) {
        errorDescription = errorMessage
    }

    public var description: String {
        return errorDescription ?? "MagicBellError"
    }
}
