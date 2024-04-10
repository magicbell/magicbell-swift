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

    // Mark: - Initializers
    
    // private initializer
    private init(maybeExternalId: String?, maybeEmail: String?, maybeHmac: String?) {
        self.externalId = maybeExternalId
        self.email = maybeEmail
        self.hmac = maybeHmac
        self.key = UserQuery.preferedKey(email: self.email, externalId: self.externalId)
    }
    
    convenience init(externalId: String, email: String, hmac: String?) {
        self.init(maybeExternalId: externalId, maybeEmail: email, maybeHmac: hmac)
    }

    convenience init(externalId: String, hmac: String?) {
        self.init(maybeExternalId: externalId, maybeEmail: nil, maybeHmac: hmac)
    }

    convenience init(email: String, hmac: String?) {
        self.init(maybeExternalId: nil, maybeEmail: email, maybeHmac: hmac)
    }
    
    // Mark: - Helper
    
    // externalID is prefered over email for key
    static func preferedKey(email: String?, externalId: String?) -> String {
        if let externalId = externalId {
            return externalId
        } else if let email = email {
            return email
        } else {
            Swift.fatalError("Either a users email, or an external Id is required")
        }
    }
}
