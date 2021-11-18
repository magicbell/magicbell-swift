//
//  MappingError.swift
//  MagicBell
//
//  Created by Javi on 19/11/21.
//

import Foundation

public class MappingError<T>: LocalizedError {
    public var errorDescription: String? {
        if error is DecodingError {
            return "Error during encoder/decoder for class \(T.self) -- \(error.localizedDescription)"
        } else {
            return "There was an error during Mapping but it isn't an error from Codable \(T.self) -- \(error.localizedDescription)"
        }
    }

    private let error: Error

    public init(_ error: Error) {
        self.error = error
    }
}
