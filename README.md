# MagicBell iOS SDK

This is the official [MagicBell](https://magicbell.com) SDK project for iOS. You can easily fetch, monitor, and modify notifications.

The whole SDK library has been built on Swift, and runs starting iOS 12.0 and above.

To run the example project, clone the repo, and run `pod install` from the `Example` directory, open the `Example/Example.xcworkspace`, and run the Example project target.

To run the MagicBell tests or to apply changes on the MagicBell iOS SDK, clone the repo, run `pod install` from the root directory, and open the `MagicBell.xcworkspace`.

## Quick Start

First, grab your API key from your [MagicBell dashboard](https://app.magicbell.com).

Then install the iOS SDK in your project and start fetching your notifications:

```swift
import MagicBell

// Create the MagicBell instance
let magicBell = MagicBell(apiKey: "YOUR_API_KEY")

// Authenticate a user
let user = magicBell.forUser(email: "john@doe.com")

// Obtain a notification store for all notifications
let store = user.store.forAll()

// Fetch the first page of the list of notifications
store.fetch { result in 
    if let notifications = try? result.get() {
         // Print the unread count
        print("Count: \(store.unreadCount)")

        // Print the loaded notifications
        print("notifications: \(notifications)")
    }
}
```

# Table of Contents

- [Installation](#installation)
- [MagicBell Setup](#magicbell-setup)
- [Authenticate a User](#authenticate-a-user)
    - [Logout](#logout-a-user)
    - [Multi-User Support](#multi-user-support)
- [NotificationStore](#notificationstore)
    - [Obtaining a NotificationStore](#obtaining-a-notification-store)
    - [Using a NotificationStore](#using-a-notification-store)
    - [Editing notifications](#editing-notifications)
    - [Observing NotificationStore changes](#observing-notification-store-changes)
- [User Preferences](#user-preferences)
- [Push Notification Support](#push-notifications)

## Installation

MagicBell is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MagicBell', :git => 'https://github.com/magicbell-io/magicbell-ios'
```

## MagicBell Setup

The `MagicBell` object is responsible to identify a single client, and will be the entry point to authenticate users and set the APNs device token.

First, you must configure your MagicBell instance. Just create a MagicBell object as follows:

```swift 
let magicBell = MagicBell(apiKey: "YOUR_API_KEY")
```

Additionally, you might want to add more options to the initialization:

```swift 
let magicBell = MagicBell(
    apiKey: "YOUR_API_KEY"
    apiSecret: "YOUR_API_SECRET",
    enableHMAC: true | false,
    baseUrl: "CUSTOM_MAGICBELL_HOST",
    logLevel: .none | .debug
)
```


| Param | Default Value | Description |
| - | - | - |
| `apiKey` | - | Your MagicBell's API key. |
| `apiSecret` | `nil` | Your MagicBell's API Secret. |
| `enableHMAC` | `false` | Set to `true` if you want HMAC enabled. Note the `apiSecret` is required if set to `true`.
| `baseURL` | `https://api.magicbell.io` | MagicBell host. Only customize if running a private instance of MagicBell. |
| `logLevel` | `.none` | Enables MagicBell logs if set to `.debug`.|


## Managing the MagicBell's instance

You might want to make your `magicBell` instance accessible from all of your app. 

Therefore, you can instantiate it in the `AppDelegate.swift` or `App.swift` file (or any other file) as a constant value. 

```swift
import UIKit
import MagicBell
import UserNotifications

let magicBell = MagicBell(apiKey: "YOUR_API_KEY")

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    ...
}
```


Otherwise, you can inject it in your dependency injection graph as you please.

## Authenticate a User

Next step is to **identify your user** to start fetching notifications. 

This is the responsibility of the `UserBell` class, which will give access to all notifications and user preferences for a given user.

To obtain the `UserBell` class for a given user, you must use the previously defined `magicBell` instance and call the method `forUser(...)` chosing among the three options MagicBell provide:

```swift
// Identify the user by its email
let user = magicBell.forUser(email: "john@doe.com")

// Identify the user by its external id
let user = magicBell.forUser(externalId: "123456789")

// Identify the user by oth, email and external id
let user = magicBell.forUser(email: "john@doe.com", externalId: "123456789")
```

Note that `MagicBell` will create a `UserBell` instance the first time you access that user, but subsequent calls **will return the same instance**, keeping alive the user loaded notifications stack and real-time updates.

```swift
let user1 = magicBell.forUser(email: "john@doe.com")
let user2 = magicBell.forUser(email: "john@doe.com")

assert(user1 === user2, "Both users must be the same instance")
```
### Logout a User

To stop the MagicBell service in an authenticated user, you must notify the MagicBell instance as follows:

```swift
// Remove by email
magicBell.removeUserFor(email: "john@doe.com")

// Remove by external id
magicBell.removeUserFor(externalId: "123456789")

// Remove by email and external id
magicBell.removeUserFor(email: "john@doe.com", externalId: "123456789")
```

By calling this method, MagicBell will delete all notification stores from memory and stop real-time connections. It also will unregister the APN device token from that user.

Its important to not retain any reference to `NotificationStore` instances from a given user after login out that user.

### Multi-User Support

Note MagicBell supports multiple users simultaneously. Just obtain multiple instances of `UserBell` by calling `forUser(:)` with different emails/externalId.

This is very useful if your app suports multiple logins, and you want to display the status of notifications of all users at the same time.

## Managing UserBell's instances

In order to retrieve notifications you'll need to access the `UserBell` instance. To achieve this there are multiple options:

### A) Extend your user object

This approach is useful if you have a user object accross your app. MagicBell will guarantee the `UserBell` instance for a given email/externalId is unique, and you only need to provide access to the instance. For example:

```swift
// Your custom user object
struct User {
    let name: String
    let email: String
}

extension User {
    // MagicBell extension to obtain the UserBell of that user
    func magicBell() -> UserBell {
        return magicBell.forUser(email: email)
    }
}
```

### B) Assing a global attribute

As you create a `magicBell` instance, you can define an optional value `userBell` that will represent your user notifications.

```swift
let magicBell = MagicBell(apiKey: "YOUR_API_KEY")
var userBell: UserBell? = nil
```

As soon as you perform a login, assing the attribute and you'll have it globaly available on your app.

Note this approach introduces an optional check on `userBell` you'll need to perform across your app, as if the user is not logged in yet, there is no `userBell` available.

### C) User your own dependency injection graph

Obviously, you could inject the `userBell` instance in your own graph and keep track on it using your preferred pattern.

## NotificationStore

### Obtaining a Notification Store

The `NotificationStore` class represents a collection of [MagicBell](https://magicbell.com)
notifications.  Specifically, to obtain a notification store you must provide a custom `StorePredicate`, which will define the exact collection of notifications.

```swift
let store = user.store.with(predicate: StorePredicate(...))
```

To create a `StorePredicate`, you must provide which type of notifications you want, chosing among the following options:

| Param | Options | Default |
| - | - | - |
| `read` | `.read`, `.unread`, `.unspecified` | `.unspecified` |
| `seen` | `.seen`, `.unseen`, `.unspecified` | `.unspecified` |
| `archived` | `.archived`, `.unarchived`, `.unspecified` | `.unspecified` |
| `categories` | `[String]` | `[]` |
| `topics` | `[String]` | `[]` |

For example, we could fetch unread notifications that belong to category `"important"`.

```swift
let store = user.store.with(predicate: StorePredicate(read: .unread, categories: ["important"]))
```
To obtain all notifications, just use the default `StorePredicate`:

```swift
let store = user.store.with(predicate: StorePredicate())
```

**Important**

Note MagicBell will keep an obtained store alive and subsequential requests of that store will return the same instance. This is done in order to keep that instance alive and receiving real-time updates.

To force a deletion of a `NotificationStore` instance, use the method `user.store.dispose(with: StorePredicate)`. 

### Convenience Methods

For convenience purposes, MagicBell supports the following methods for quick access:

```swift
// All notifications. Same as: StorePredicate()
let store =  user.store.forAll()

// Read notifications. Same as: StorePredicate(read: .read)
let store =  user.store.forRead()

// Unread notifications. Same as: StorePredicate(read: .unread)
let store =  user.store.forUnread()

// Notifications belonging to categories. Same as: StorePredicate(categories: ["category1", "category2"])
let store =  user.store.forCategories(["category1", "category2"])

// Notifications belonging to topics. Same as: StorePredicate(topics: ["topic1", "topic2"])
let store =  user.store.forTopics(["topic1", "topic2"])
```

For any other combination, use `user.store.with(predicate:)`.


### Using a notification store

Find below the list of methods and attributes:

| Attributes | Type | Description |
| - | - | - |
| `predicate` | `StorePredicate` | The predicate used to determine the collection of notifications |
| `totalCount` | `Int` | The notifications total counter |
| `unreadCount` | `Int`| The unread counter|
| `unseenCount` | `Int`| The unseen counter |
| `hasNextPage` | `Bool`| `true` if a next page can be loaded, `false` otherwise |
| `count` | `Int` | The number of notifications loaded in the store|


| Method | Return Type | Description |
| - | - | - |
| `subscript(index:)` | `Notification` | Subscript to access the notifications: `store[index]` |
| `refresh` | `Result<[Notification], Error>` | Clears the list of notifications and refreshes the first page |
| `fetch` | `Result<[Notification], Error>` | Fetches the next page of notifications |

### Loading Notifications

There are two methods to load notifications:

- `store.fetch`: Use this method to load the first & follwoing pages in the list of notifications. The completion block returns an array with the newly loaded notifications.
- `store.refresh`: Use this method to reload from the beginning the first page of the list of notifications. The completion block returns an array with the loaded notifications.

Note by calling these methods, `NotificationStore` will notify the content observers with the newly added notifications (read about observers [here](#observing-notification-store-changes))

```swift
// Obtaining a new notification store (first time)
let store = user.store.forAll()

// First loading
store.fetch { result in 
    if let notifications = try? result.get() {
        print("Notifications: \(notifications))")

        // If store has next page available
        if store.hasNextPage {
            // Load next page
            store.fetch { result in 
                if let notifications = try? result.get() {
                    print("Notifications: \(notifications))")
                }
            }
        }
    }
}
```
To refresh the whole list of notifications:

```swift
store.refresh { result in 
    if let notifications = try? result.get() {
        print("Notifications: \(notifications))")
    }
}
```

### Accessing Loaded Notifications

`NotificationStore` inherits from `Collection`, making it an iterable collection to access its elements (as it was an array). Therefore, notifications can be accessed as expected:

```swift
// Option 1
for i in 0..<store.count {
    let notification = store[i]
    print("notification: \(notification)")
}
// Option 2
store.forEach { notification in
    print("notification: \(notification)")
}
// Option 3
for notification in store {
    print("notification: \(notification)")
}

// Enumeration is also available

// Option 4
store.enumerated().forEach { idx, notification in
    print("notification[\(idx)] = \(notification)")
}
// Option 5
for (idx, notification) in store.enumerated() {
    print("notification[\(idx)] = \(notification)")
}
```

### Editing Notifications

`NotificationStore` is the class containing methods to manipulate `Notification` objects.

```swift
// Delete notification
public func delete(_ notification: Notification, completion: @escaping (Error?) -> Void)
// Mark notification as read
public func markAsRead(_ notification: Notification, completion: @escaping (Error?) -> Void)
// Mark notification as unread
public func markAsUnread(_ notification: Notification, completion: @escaping (Error?) -> Void)
// Archive notification
public func archive(_ notification: Notification, completion: @escaping (Error?) -> Void)
// Unarchive notification
public func unarchive(_ notification: Notification, completion: @escaping (Error?) -> Void)
```

Additionaly, find methods to apply changes to all notifications (belonging to any given store):
```swift
// Mark all notificaitons as read
public func markAllRead(completion: @escaping (Error?) -> Void)
// Mark all notifications as seen
public func markAllSeen(completion: @escaping (Error?) -> Void)
```

**Important**

When editing a notification with methods above, changes will be applied localy on the store, and using the real-time syncronization system stores implement, will cascade and apply to any given store. 

For example, as a result of marking a notification read, if your store specifies in its predicate `read: .unread`, the notification must be removed from the list of notifications of that store. 

Therefore, when notification changes are detected, notification stores are updated automatically and observers of the notification stores are notified accordingly.

### Observing notification store changes

`NotificationStore` objects are automatically updated when new notifications arrive, or a notification is modified (marked read, archived, etc.)

To observe changes on a notification store, your observers must implement the following protocols:

```swift 
// Get notified when the list of notifications of a notification store changes
public protocol NotificationStoreContentObserver: AnyObject {
    func didReloadStore(_ store: NotificationStore)
    func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int])
    func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int])
    func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int])
}

// Get notified when the counters of a notification store change
public protocol NotificationStoreCountObserver: AnyObject {
    func store(_ store: NotificationStore, didChangeTotalCount count: Int)
    func store(_ store: NotificationStore, didChangeUnreadCount count: Int)
    func store(_ store: NotificationStore, didChangeUnseenCount count: Int)
}
```

To observe changes, implement these protocols (or one of them), and register as an observer to a notification store.

```swift
let store = user.store.forAll()
let observer = myObserverClassInstance

store.addContentObserver(observer)
store.addCountObserver(observer)
```
MagicBell will provide a Swift Combine-based observation pattern in a future version of the SDK.

## User Preferences

The user preferences object contains multiple configuration options:

```swift
public class Preferences {
    var email: Bool
    var inApp: Bool
    var mobilePush: Bool
    var webPush: Bool
}

public struct UserPreferences {
    let preferences: [String: Preferences]
}
```

To fetch user preferences, do as follows:

```swift
user.userPreferences.fetch { result in
    if let userPreferences = try? result.get() {
        print("User Preferences: \(userPreferences)")
    }
}
```
Additionaly, it is possible to fetch directly a cateogry:

```swift
user.userPreferences.fetchPreferences(for: "my_category") { result in
    if let category = try? result.get() {
        print("Category: \(category)")
    }
}
```

To update user preferences, use one of the two methods supported in the SDK.

```swift
// Updating the whole list of preferences at once.
// Only the included categories will be affected.
user.userPreferences.update(userPreferences) { result in }

// Updating the list of preferences for a given category
user.userPreferences.updatePreferences(categoryPreferences, for: "my_category") { result in }
```

## Push Notifications

To support push notifications, the only requirement is to set to MagicBell the device token as soon as it is provided by iOS.

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Storing device token when refreshed
    magicBell.setDeviceToken(deviceToken: deviceToken)
}
```

MagicBell will keep that device token stored temporarly in memory and send it as soon as new users are declared via `MagicBell.forUser`.

Upon logout of a user (`MagicBell.removeUserFor`), the device token is unregistered from that user.