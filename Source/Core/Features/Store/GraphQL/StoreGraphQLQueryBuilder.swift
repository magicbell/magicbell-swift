//
//  GraphQLBuilder.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation

struct StoreGraphQLQueryBuilder {
    let graphQLPredicates: [GraphQLPredicate]

    init(storeContexts: [StoreContext]) {
        self.graphQLPredicates = storeContexts.map { storeContext in
            StoreGraphQLPredicate(storeContext: storeContext)
        }
    }

    init(storeContext: StoreContext) {
        self.init(storeContexts: [storeContext])
    }

    private let fragment: Fragment = .fragmentNotification
    var graphQLQuery: String {
        var query = "query {"
        query.append(graphQLPredicates.map {
            $0.query
        }.joined(separator: " \n "))
        query.append("} \n")
        query.append(fragment.rawValue)
        return query
    }

    enum Fragment: String {
        case fragmentNotification = """
                                            fragment notification on NotificationsConnection {
                                              edges {
                                                cursor
                                                node {
                                                  id
                                                  title
                                                  content
                                                  actionUrl
                                                  archivedAt
                                                  category
                                                  topic
                                                  customAttributes
                                                  readAt
                                                  seenAt
                                                  sentAt
                                                }
                                              }
                                              pageInfo {
                                                endCursor
                                                hasNextPage
                                                hasPreviousPage
                                                startCursor
                                              }
                                              totalCount
                                              unreadCount
                                              unseenCount
                                            }
                                    """
    }
}
