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
import Harmony

struct StoreQuery: Query {
    let context: StoreContext
    let userQuery: UserQuery

    init(storePredicate: StorePredicate,
         storePagePredicate: StorePagePredicate,
         userQuery: UserQuery) {
        self.init(
            context: StoreContext(storePredicate, storePagePredicate),
            userQuery: userQuery
        )
    }

    init(context: StoreContext, userQuery: UserQuery) {
        self.context = context
        self.userQuery = userQuery
    }
}
