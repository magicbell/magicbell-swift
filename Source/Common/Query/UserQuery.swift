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

class UserQuery: KeyQuery {
    let externalId: String?
    let email: String?
    let hmac: String?
    let key: String

    init(externalId: String, email: String, hmac: String?) {
        self.externalId = externalId
        self.email = email
        self.key = externalId
        self.hmac = hmac
    }

    init(externalId: String, hmac: String?) {
        self.externalId = externalId
        self.email = nil
        self.key = externalId
        self.hmac = hmac
    }

    init(email: String, hmac: String?) {
        self.externalId = nil
        self.email = email
        self.key = email
        self.hmac = hmac
    }
}
