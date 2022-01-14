//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
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
        let bundle = Bundle(for: MagicBellClient.self)
        guard let url = bundle.url(forResource: filename, withExtension: "graphql") else {
            fatalError("Missing file \(filename).graphql")
        }
        guard let string = try? String(contentsOf: url) else {
            fatalError("Filed to open \(filename).graphql")
        }
        return string
    }
}
