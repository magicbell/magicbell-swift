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

/// The notification channel and its status
public struct Channel {
    public let label: String
    public let slug: String
    public let enabled: Bool
}

/// The category with its notification channels
public struct Category {
    public let channels: [Channel]
    public let label: String
    public let slug: String
}

/// The notification prefrences object
public struct UserPreferences {
    public let categories: [Category]
}
