# MagicBell iOS SDK

## 3.0.0

### Major Changes

- 0506e7c: Updated topic and category filtering APIs in `StorePredicate`

  Previously one was able to filter for multiple topics and categories, but this functionality is now deprecated in favor of only filtering for a single topic and category.
  Please reach out to us via the [Community](http://www.magicbell.com/community) if you need the previous functionality.

### Minor Changes

- 0506e7c: Internal: Fetching notifications from `/notifications` endpoint instead of GraphQL

## 2.0.0

This release is mostly compatible with version 1.0.0 of the SDK. It introduces two breaking changes though. Please consult the Readme for detailed reference.

### Breaking: Updated Notification Preferences API

The shape of the returned preferences object changed and now contains categories and channels.

### Breaking: HMAC validation

Instead of being required to pass the API secret, the HMAC should be computed on backend and passed to the frontend, where it is expected as an argument on the connectUser call.
Also the MagicBellClient does not have a enableHMAC flag anymore. The behaviour whether to send an HMAC header is now defined by whether one was passed as an argument to the connectUser call.

### APNS Integration

The previous SDK was registering device tokens using the /push_subscriptions API endpoint. Since version 2, the SDK uses /integrations/mobile_push/apns.
