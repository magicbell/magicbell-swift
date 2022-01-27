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
        switch filename {
        case "NotificationFragment":
            return  """
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
        default:
            fatalError("Missing fragment")
        }
    }
}
