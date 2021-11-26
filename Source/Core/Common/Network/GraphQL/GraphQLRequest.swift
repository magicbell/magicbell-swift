//
//  GraphQLBuilder.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation

struct GraphQLRequest: GraphQLRepresentable {
    enum Fragment {
        case notification

        func value() -> String {
            let fileName: String = {
                switch self {
                case .notification:
                    return "NotificationFragment"
                }
            }()
            guard let url = Bundle(for: MagicBell.self).url(forResource: fileName, withExtension: "graphql") else {
                fatalError("Missing file \(fileName).graphql")
            }
            guard let string = try? String(contentsOf: url) else {
                fatalError("Filed to open \(fileName).graphql")
            }
            return string
        }
    }

    let predicates: [GraphQLRepresentable]
    let fragment: Fragment

    init(predicates: [GraphQLRepresentable], fragment: Fragment) {
        self.predicates = predicates
        self.fragment = fragment
    }

    init(predicate: GraphQLRepresentable, fragment: Fragment) {
        self.init(predicates: [predicate], fragment: fragment)
    }

    var graphQLValue: String {
        var query = "query {"
        query.append(predicates.map {
            $0.graphQLValue
        }.joined(separator: "\n "))
        query.append("} \n")
        query.append(fragment.value())
        return query
    }
}
