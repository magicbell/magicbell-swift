//
//  GraphQLBuilder.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
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
