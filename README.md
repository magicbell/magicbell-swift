# MagicBell iOS SDK

This is the official [MagicBell](https://magicbell.com) SDK project for iOS. You can easily fetch, monitor, and modify notifications.

The whole SDK library has been built on Swift, and runs starting iOS 12.0 and above.

To run the example project, clone the repo, and run `pod install` from the root directory, open the `MagicBell.xcworkspace`, and run the Example project target.

## Quick Start

First, grab your API key from your [MagicBell dashboard](https://app.magicbell.com).

Then install the iOS SDK in your project and start fetching your notifications.

## Installation

MagicBell is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MagicBell'
```

## Table of Contents

- [MagicBell Setup](#magicbellsetup)
- [Authenticate a User](#create-notifications)
- [NotificationStore](#notificationstore)
- [User Preferences](#notification)
- [Push Notification Support](#apnssuport)

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


### Managing the MagicBell's instance

You might want to make your `magicBell` instance accessible from all of your app. 

Therefore, you can instantiate it in the `AppDelegate.swift` file (or any other file) as a constant value. Otherwise, you can inject it in your dependency injection graph as you please.

## Authenticate a User









