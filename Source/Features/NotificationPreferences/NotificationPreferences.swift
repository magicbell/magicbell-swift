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
    public let slug: String
    public let label: String
    public let enabled: Bool
    
    public init(slug: String, label: String, enabled: Bool) {
        self.slug = slug
        self.label = label
        self.enabled = enabled
    }
}

/// The category with its notification channels
public struct Category {
    public let slug: String
    public let label: String
    public let channels: [Channel]
    
    public init(slug: String, label: String, channels: [Channel]) {
        self.slug = slug
        self.label = label
        self.channels = channels
    }
}

/// The notification prefrences object containing all categories
public struct NotificationPreferences {
    public let categories: [Category]
    
    public init(categories: [Category]) {
        self.categories = categories
    }
}
