//
//  GraphQLFragment.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

struct GraphQLFragment: GraphQLRepresentable {
    let filename: String

    /// Main initializer
    /// - Parameter filename: The filename without extension. The file's  extension must be ".graphql".
    init(filename: String) {
        self.filename = filename
    }

    var graphQLValue: String {
        guard let url = Bundle(for: MagicBell.self).url(forResource: filename, withExtension: "graphql") else {
            fatalError("Missing file \(filename).graphql")
        }
        guard let string = try? String(contentsOf: url) else {
            fatalError("Failed to open \(filename).graphql")
        }
        return string
    }
}
