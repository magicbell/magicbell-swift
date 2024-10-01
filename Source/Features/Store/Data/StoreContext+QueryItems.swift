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

extension StorePredicate {
    var asQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        ["read": read,
         "seen": seen,
         "archived": archived].forEach { (key: String, value: Bool?) in
            if let value = value {
                queryItems.append(URLQueryItem(name: key, value: value.description))
            }
        }

        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        if let topic = topic {
            queryItems.append(URLQueryItem(name: "topic", value: topic))
        }

        return queryItems
    }
}


extension StorePagePredicate {
    var asQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        ["page": page,
         "per_page": size].forEach { (key: String, value: Int?) in
            if let value = value {
                queryItems.append(URLQueryItem(name: key, value: value.description))
            }
        }

        return queryItems
    }
}


extension StoreContext {
    var asQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        queryItems.append(contentsOf: self.store.asQueryItems)
        queryItems.append(contentsOf: self.page.asQueryItems)

        return queryItems
    }
}
