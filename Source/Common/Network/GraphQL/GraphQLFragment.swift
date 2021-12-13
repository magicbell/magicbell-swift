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
        return """
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
