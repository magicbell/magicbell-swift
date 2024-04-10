# MagicBell iOS SDK

This is the official [MagicBell](https://magicbell.com) SDK for iOS.

This SDK offers:

- Real-time updates
- Low-level wrappers for the MagicBell API
- Support for the [Combine framework](https://developer.apple.com/documentation/combine)

It requires:

- iOS 12.0+
- Swift 5.3+
- Xcode 12+

## Quick Start

First, grab your API key from your [MagicBell dashboard](https://app.magicbell.com). Then, initialize the client and set
the current user:

```swift
import MagicBell

// Create the MagicBell client with your project's API key
let client = MagicBellClient(apiKey: "[MAGICBELL_API_KEY]")

// Set the MagicBell user
let user = client.connectUser(email: "richard@example.com")

// Create a store of notifications
let store = user.store.build()

// Fetch the first page of notifications
store.fetch { result in
    if let notifications = try? result.get() {
        // Print the unread count
        print("Count: \(store.unreadCount)")

        // Print the fetched notifications
        print("notifications: \(notifications)")
    }
}
```

This repo also contains a full-blown example. To run the project:

- Clone the repo
- Run `pod install` from the `Example` directory
- Open the Example project in XCode
- Run the Example project target

## Table of Contents

- [Installation](#installation)
- [The MagicBell client](#the-magicbell-client)
- [User](#user)
  - [Multi-User Support](#multi-user-support)
  - [Logout a user](#logout-a-user)
  - [Integrating into your app](#integrating-into-your-app)
- [NotificationStore](#notificationstore)
  - [Advanced filters](#advanced-filters)
  - [Observing changes](#observing-changes)
  - [Accessing notifications](#accessing-notifications)
- [User Preferences](#user-preferences)
- [Push Notification Support](#push-notifications)
- [Contributing](#contributing)

## Installation

### CocoaPods

To install MagicBell using [CocoaPods](https://cocoapods.org), add this entry to your `Podfile`:

```ruby
pod 'MagicBell', '>=1.0.0'
```

**IMPORTANT**: Make sure you specify `use_frameworks!` in your `Podfile`.

Then, run `pod install`.

### Swift Package Manager

To install MagicBell using [Swift Package Manager](https://www.swift.org/package-manager/), just add the dependency as follows to your project:

```swift
dependencies: [
    .package(url: "https://github.com/magicbell-io/magicbell-swift", .upToNextMajor(from: "1.0.0"))
]
```

### Carthage

To install MagicBell using [Carthage](https://github.com/Carthage/Carthage), add to the Carfile the following dependency:

```ruby
github "magicbell-io/magicbell-swift" "1.0.0"
```

Then, run `carthage update --use-xcframeworks --platform [iOS|macOS] --no-use-binaries` (selecting the desired platform) to resolve dependencies.

Add the `MagicBell.xcframework` to your project-linked frameworks, together with the other dependencies resolved by Carthage.

## The MagicBell Client

The first step is to create a `MagicBellClient` instance. It will manage users and other functionality for you. The API
key for your MagicBell project is required to initialize it.

```swift
let magicbell = MagicBellClient(apiKey: "[MAGICBELL_API_KEY]")
```

You can provide additional options when initializing a client:

```swift
let magicbell = MagicBellClient(
    apiKey: "[MAGICBELL_API_KEY]"
    enableHMAC: true,
    logLevel: .debug
)
```

| Param        | Default Value | Description                                                                                  |
| ------------ | ------------- | -------------------------------------------------------------------------------------------- |
| `apiKey`     | -             | Your MagicBell's API key                                                                     |
| `apiSecret`  | `nil`         | Your MagicBell's API secret                                                                  |
| `enableHMAC` | `false`       | Set it to `true` if you want HMAC enabled. Note the `apiSecret` is required if set to `true` |
| `logLevel`   | `.none`       | Set it to `.debug` to enable logs                                                            |

Though the API key is meant to be published, you should not distribute the API secret. Rather, enable HMAC for your
project and generate the user secret on your backend before distributing your app.

### Integrating into your app

You should create the client instance as early as possible in your application and ensure that only one instance is used
across your application.

```swift
import MagicBell

// Store the instance at a place of your convenience
let magicbell = MagicBellClient(apiKey: "[MAGICBELL_API_KEY]")
```

Optionally, you could assign the unique instance as a static shared instance inside the `MagicBellClient`.

```swift
import MagicBell

extension MagicBellClient {
    static var shared = MagicBellClient(apiKey: "[MAGICBELL_API_KEY]")
}
```

## User

Requests to the MagicBell API require that you **identify the MagicBell user**. This can be done by calling the
`connectUser(...)` method on the `MagicBellClient` instance with the user's email or external ID:

```swift
// Identify the user by its email
let user = magicbell.connectUser(email: "richard@example.com")

// Identify the user by its external id
let user = magicbell.connectUser(externalId: "001")

// Identify the user by both, email and external id
let user = magicbell.connectUser(email: "richard@example.com", externalId: "001")
```

Each variant of `connectUser` supports an optional `hmac` parameter that is required if `enableHMAC` is enabled when initiating the `MagicBellClient`.

You can connect as [many users as you need](#multi-user-support).

**IMPORTANT:** `User` instances are singletons. Therefore, calls to the `connectUser` method with the same arguments will
yield the same user:

```swift
let userOne = magicbell.connectUser(email: "mary@example.com")
let userTwo = magicbell.connectUser(email: "mary@example.com")

assert(userOne === userTwo, "Both users reference to the same instance")
```

### Multi-User Support

If your app supports multiple logins, you may want to display the status of notifications for all logged-in users
simultaneously. The MagicBell SDK allows you to do that.

You can call the `connectUser(:)` method with the email or external ID of your logged in users as many times as you
need.

```swift
let userOne = magicbell.connectUser(email: "richard@example.com")
let userTwo = magicbell.connectUser(email: "mary@example.com")
let userThree = magicbell.connectUser(externalId: "001")
```

### Logout a User

When the user is logged out from your application you want to:

- Remove user's notifications from memory
- Stop the real-time connection with the MagicBell API
- Unregister the device from push notifications

This can be achieved with the `disconnectUser` method of the `MagicBell` client instance:

```swift
// Remove by email
magicbell.disconnectUser(email: "richard@example.com")

// Remove by external id
magicbell.disconnectUser(externalId: "001")

// Remove by email and external id
magicbell.disconnectUser(email: "richard@example.com", externalId: "001")
```

### Integrating into your app

The MagicBell `User` instances need to be available accross your app. Here you have some options:

- extend your own user object
- define a global attribute
- use your own dependency injection graph

#### Extend your own user object

This approach is helpful if you have a user object accross your app. MagicBell will guarantee the `User` instance for a
given email/externalId is unique, and you only need to provide access to the instance. For example:

```swift
import MagicBell

// Your own user
struct User {
    let name: String
    let email: String
}

extension User {
    /// Returns the logged in MagicBell user
    func magicBell() -> MagicBell.User {
        return magicbell.connectUser(email: email)
    }
}
```

#### Define a global attribute

This is how you can define a nullable global variable that will represent your MagicBell user:

```swift
import MagicBell

let magicbell = MagicBellClient(apiKey: "[MAGICBELL_API_KEY]")
var magicbellUser: MagicBell.User? = nil
```

As soon as you perform a login, assign a value to this variable. Keep in mind you will have to check the
`magicbellUser` variable was actually set before accessing it in your code.

#### Use your own dependency injection graph

You can also inject the MagicBell `User` instance into your own graph and keep track of it using your preferred pattern.

## NotificationStore

The `NotificationStore` class represents a collection of [MagicBell](https://magicbell.com) notifications. You can
create an instance of this class through the `.build(...)` method on the user store object.

For example:

```swift
let allNotifications = user.store.build()

let readNotifications = user.store.build(read: true)

let unreadNotifications = user.store.build(read: false)

let archviedNotifications = user.store.build(archived: true)

let billingNotifications = user.store.build(categories: ["billing"])

let firstOrderNotifications = user.store.build(topics: ["order:001"])
```

These are the attributes of a notification store:

| Attributes    | Type             | Description                                                  |
| ------------- | ---------------- | ------------------------------------------------------------ |
| `totalCount`  | `Int`            | The total number of notifications                            |
| `unreadCount` | `Int`            | The number of unread notifications                           |
| `unseenCount` | `Int`            | The number of unseen notifications                           |
| `hasNextPage` | `Bool`           | Whether there are more items or not when paginating forwards |
| `count`       | `Int`            | The current number of notifications in the store             |
| `predicate`   | `StorePredicate` | The predicate used to filter notifications                   |

And these are the available methods:

| Method              | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| `refresh`           | Resets the store and fetches the first page of notifications |
| `fetch`             | Fetches the next page of notifications                       |
| `subscript(index:)` | Subscript to access the notifications: `store[index]`        |
| `delete`            | Deletes a notification                                       |
| `delete`            | Deletes a notification                                       |
| `markAsRead`        | Marks a notification as read                                 |
| `markAsUnread`      | Marks a notification as unread                               |
| `archive`           | Archives a notification                                      |
| `unarchive`         | Unarchives a notification                                    |
| `markAllRead`       | Marks all notifications as read                              |
| `markAllUnseen`     | Marks all notifications as seen                              |

Most methods have two implementations:

- Using completion blocks (returning a `Result` object)
- Returning a Combine `Future` (available on iOS 13+)

```swift
// Delete notification
store.delete(notification) { result in
    switch result {
    case .success:
        print("Notification deleted")
    case .failure(error):
        print("Failed: \(error)")
    }
}

// Read a notification
store.markAsRead(notification)
    .sink { error in
        print("Failed: \(error)")
    } receiveValue: { notification in
        print("Notification marked as read")
    }
```

These methods ensure the store's state is consistent when a notification changes. For example, when a notification
is read, stores with the predicate `read: .unread`, will remove that notification from themselves, notifying all
observers of the notification store.

### Advanced filters

You can also create stores with more advanced filters. To do it, fetch a store using the `.build(...)` method with a
`StorePredicate`.

```swift
let predicate = StorePredicate()
let notifications = user.store.build(predicate: predicate)
```

These are the available options:

| Param        | Options                | Default | Description                                          |
| ------------ | ---------------------- | ------- | ---------------------------------------------------- |
| `read`       | `true`, `false`, `nil` | `nil`   | Filter by the `read` state (`nil` means unspecified) |
| `seen`       | `true`, `false`, `nil` | `nil`   | Filter by the `seen` state (`nil` means unspecified) |
| `archived`   | `true`, `false`        | `false` | Filter by the `archived` state                       |
| `categories` | `[String]`             | `[]`    | Filter by catregories                                |
| `topics`     | `[String]`             | `[]`    | Filter by topics                                     |

For example, use this predicate to fetch unread notifications of the `"important"` category:

```swift
let predicate = StorePredicate(read: .unread, categories: ["important"])
let store = user.store.build(predicate: predicate)
```

Notification stores are singletons. Creating a store with the same predicate twice will yield the same instance.

**Note**: Once a store is fetched, it will be kept alive in memory so it can be updated in real-time. You can force the
removal of a store using the `.dispose` method.

```swift
let predicate = StorePredicate()
user.store.dispose(with: predicate)
```

This is automatically done for you when you [remove a user instance](#logout-a-user).

### Observing changes

When either `fetch` or `refresh` is called, the store will notify the content observers with the newly added
notifications (read about observers [here](#observing-notification-store-changes)).

```swift
// Obtaining a new notification store (first time)
let store = user.store.build()

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

To reset and fetch the store:

```swift
store.refresh { result in
    if let notifications = try? result.get() {
        print("Notifications: \(notifications))")
    }
}
```

### Accessing notifications

The `NotificationStore` is an iterable collection. Therefore, notifications can be accessed as expected:

```swift
for i in 0..<store.count {
    let notification = store[i]
    print("notification: \(notification)")
}

// forEach
store.forEach { notification in
    print("notification: \(notification)")
}

// for in
for notification in store {
    print("notification: \(notification)")
}

// As an array
let notifications = store.notifications()
```

Enumeration is also available:

```swift
// forEach
store.enumerated().forEach { idx, notification in
    print("notification[\(idx)] = \(notification)")
}

// for in
for (idx, notification) in store.enumerated() {
    print("notification[\(idx)] = \(notification)")
}
```

### Observing notification store changes

#### Classic Observer Approach

Instances of `NotificationStore` are automatically updated when new notifications arrive, or a notification's state
changes (marked read, archived, etc.)

To observe changes on a notification store, your observers must implement the following protocols:

```swift
// Get notified when the list of notifications of a notification store changes
protocol NotificationStoreContentObserver: AnyObject {
    func didReloadStore(_ store: NotificationStore)
    func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int])
    func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int])
    func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int])
    func store(_ store: NotificationStore, didChangeHasNextPage hasNextPage: Bool)
}

// Get notified when the counters of a notification store change
protocol NotificationStoreCountObserver: AnyObject {
    func store(_ store: NotificationStore, didChangeTotalCount count: Int)
    func store(_ store: NotificationStore, didChangeUnreadCount count: Int)
    func store(_ store: NotificationStore, didChangeUnseenCount count: Int)
}
```

To observe changes, implement these protocols (or one of them), and register as an observer to a notification store.

```swift
let store = user.store.build()
let observer = myObserverClassInstance

store.addContentObserver(observer)
store.addCountObserver(observer)
```

#### Reactive Approach (iOS 13)

Use the class `NotificationStorePublisher` to create an `ObservableObject` capable of publishing changes on the main
attributes of a `NotificaitonStore`.

This object must be created and retained by the user whenever it is needed.

| Attribute       | Type                        | Description                                        |
| --------------- | --------------------------- | -------------------------------------------------- |
| `totalCount`    | `@Published Int`            | The total count                                    |
| `unreadCount`   | `@Published Int`            | The unread count                                   |
| `unseenCount`   | `@Published Int`            | The unseen count                                   |
| `hasNextPage`   | `@Published Bool`           | Bool indicating if there is more content to fetch. |
| `notifications` | `@Published [Notification]` | The array of notifications.                        |

A typical usage would be in a `View` of SwiftUI, acting as a view model that can be directly referenced from the view:

```swift
import SwiftUI
import MagicBell

class Notifications: View {
    let store: NotificationStore
    @ObservedObject var bell: NotificationStorePublisher

    init(store: NotificationStore) {
        self.store = store
        self.bell = NotificationStorePublisher(store)
    }

    var body: some View {
        List(bell.notifications, id: \.id) { notification in
            VStack(alignment: .leading) {
                Text(notification.title)
                Text(notification.content ?? "-")
            }
        }
        .navigationBarTitle("Notifications - \(bell.totalCount)")
    }
}
```

## Notification Preferences

You can fetch and set users notification preferences for MagicBell channels and categories.

```swift
public struct Channel {
    public let label: String
    public let slug: String
    public let enabled: Bool
}

public struct Category {
    public let channels: [Channel]
    public let label: String
    public let slug: String
}

public struct NotificationPreferences {
    public let categories: [Category]
}
```

To fetch the users notification preferences, use the `fetch` method as follows:

```swift
user.preferences.fetch { result in
    if let preferences = try? result.get() {
        print("Notification Preferences: \(preferences)")
    }
}
```

To update the preferences, use `update`.

```swift
// Updating notification preferences.
// The update can be partial and only will affect the categories included in the object being sent
user.preferences.update(preferences) { result in }
```

## Push Notifications

You can register the device token with MagicBell for mobile push notifications. To do it, set the device token as soon
as it is provided by iOS:

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Storing device token when refreshed
    magicbell.setDeviceToken(deviceToken: deviceToken)
}
```

MagicBell will keep that device token stored temporarily in memory and send it as soon as new users are declared via
`MagicBellClient.connectUser`.

When a user is disconnected (`MagicBellClient.disconnectUser`), the device token is automatically unregistered for that
user.

## Contributing

We welcome contributions of any kind. To do so, clone the repo, resolve dependencies via Carthage in the root folder by running the command `carthage update --use-xcframeworks --no-use-binaries`, and open `MagicBell.xcodeproj`.
