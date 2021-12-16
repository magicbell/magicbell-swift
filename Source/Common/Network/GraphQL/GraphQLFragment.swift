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
        let bundle = Bundle(for: MagicBell.self)
        guard let url = bundle.url(forResource: filename, withExtension: "graphql") else {
              fatalError("Missing file \(filename).graphql")
          }
          guard let string = try? String(contentsOf: url) else {
              fatalError("Filed to open \(filename).graphql")
          }
          return string
    }

    func recursivePathsForResources(type: String, in directoryPath: String) -> [String] {
        // Enumerators are recursive
        let enumerator = FileManager.default.enumerator(atPath: directoryPath)
        var filePaths: [String] = []

        while let filePath = enumerator?.nextObject() as? String {

                filePaths.append(directoryPath.appending( filePath))

        }
        return filePaths
    }
}
