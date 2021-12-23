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

struct GraphQLRequest: GraphQLRepresentable {
    let predicates: [GraphQLRepresentable]
    let fragment: GraphQLFragment

    init(predicates: [GraphQLRepresentable], fragment: GraphQLFragment) {
        self.predicates = predicates
        self.fragment = fragment
    }

    init(predicate: GraphQLRepresentable, fragment: GraphQLFragment) {
        self.init(predicates: [predicate], fragment: fragment)
    }

    var graphQLValue: String {
        var query = "query {"
        query.append(predicates.map {
            $0.graphQLValue
        }.joined(separator: "\n "))
        query.append("} \n")
        query.append(fragment.graphQLValue)
        return query
    }
}
