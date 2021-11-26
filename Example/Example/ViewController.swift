//
//  ViewController.swift
//  Example
//
//  Created by Javi on 17/11/21.
//

import UIKit
import MagicBell

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            MagicBell.configure(
                apiKey: "34ed17a8482e44c765d9e163015a8d586f0b3383",
                apiSecret: "72c5cdbba85d089d7f11ab090cb4c6773cbafaa8"
            )

            MagicBell.login(email: "javier@mobilejazz.com")

            // MagicBell.logout()

            let userQuery = UserQuery(email: "javier@mobilejazz.com")
            let notificationId = "f43fb412-b8b2-47af-bf9b-61b92b5e9c20"
            let deviceToken = "abdcde12345"

            //            // Channel Notification
            //            let getConfigNetworkDataSource = MagicBell.shared.sdkProvider.configComponent.getConfigNetworkDataSource()
            //            let config = try getConfigNetworkDataSource.get(userQuery).result.get()
            //            print("Channel for notifications --> \(config.channel)")

            let getStorePagesInteractor = MagicBell.shared.sdkProvider.storeComponent.getStorePagesInteractor()

//            getStorePagesInteractor.execute(
//                storePredicate: StorePredicate(read: .unread),
//                cursorPredicate: CursorPredicate(),
//                userQuery: userQuery
//            ).then { store in
//                print(store)
//            }.fail { error in
//                print("Error: \(error)")
//            }
            getStorePagesInteractor.execute(
                contexts: [
                    StoreContext("read", StorePredicate(read: .read), CursorPredicate()),
                    StoreContext("unread", StorePredicate(read: .unread), CursorPredicate())
                ],
                userQuery: userQuery
            ).then { stores in
                if let store = stores["read"] {
                    print("READ: \(store)")
                } else {
                    print("Missing read store")
                }
                if let store = stores["unread"] {
                    print("UNREAD: \(store)")
                } else {
                    print("Missing unread store")
                }
            }.fail { error in
                print("Error: \(error)")
            }
            return


            // User preferences
            let getUserPreferencesNetworkDataSource = MagicBell.shared.sdkProvider.userPreferencesComponent.getUserPreferencesNetworkDataSource()
            let userPreferences = try getUserPreferencesNetworkDataSource.get(userQuery).result.get()
            print("User preferences --> \(userPreferences)")

            if let categories = userPreferences.notificationPreferences?.categories {
                for key in categories.keys {
                    if let category = categories[key],
                       var inApp = category.inApp {
                        inApp.toggle()
                    }
                }
            }

            let getPutUserPreferenceNetworkDataSource = MagicBell.shared.sdkProvider.userPreferencesComponent.getPutUserPreferenceNetworkDataSource()
            let userPreferencesUpdated = try getPutUserPreferenceNetworkDataSource.put(userPreferences, in: userQuery).result.get()
            print("New user preferences --> \(userPreferencesUpdated)")


            // Notification

            let notificationDataSource = MagicBell.shared.sdkProvider.notificationComponent.getNotificationNetworkDataSource()
            let actionNotificationDataSource = MagicBell.shared.sdkProvider.notificationComponent.getActionNotificationNetworkDataSource()

            let notification = try notificationDataSource.get(NotificationQuery(notificationId: notificationId, userQuery: userQuery)).result.get()
            print("Notification --> \(notification)")

            // Mark Notification as readed
            _ = try actionNotificationDataSource.put(nil, in: NotificationActionQuery(action: .markAsRead,
                                                                                      notificationId: notificationId,
                                                                                      userQuery: userQuery)).result.get()
            let notificationReaded = try notificationDataSource.get(NotificationQuery(notificationId: notificationId,
                                                                                      userQuery: userQuery)).result.get()
            print(notificationReaded)

            // Uncomment to delete a notification
            // let deleteNotificationDataSource = MagicBell.shared.sdkProvider.notificationComponent.getDeleteNotificationNetworkDataSource()
            // _ = deleteNotificationDataSource.delete(NotificationQuery(notificationId: notificationId, userQuery: userQuery))

            // Push subscription
            let getPushSubscriptionNetworkDataSource = MagicBell.shared.sdkProvider.pushSubscriptionComponent.getPushSubscriptionNetworkDataSource()
            let pushSubscription = try getPushSubscriptionNetworkDataSource.put(
                PushSubscription(
                    deviceToken: deviceToken,
                    platform: "ios"
                ),
                in: RegisterPushSubscriptionQuery(user: userQuery)
            ).result.get()
            print("Push subscription --> \(pushSubscription)")

            // Uncomment to delete a device
            // let deletePushSubscriptionNetworkDataSource = MagicBell.shared.sdkProvider.pushSubscriptionComponent.getDeletePushSubscriptionNetworkDataSource()
            // _ = try deletePushSubscriptionNetworkDataSource.delete(DeletePushSubscriptionQuery(user: userQuery, deviceToken: deviceToken)).result.get()
        } catch let error as LocalizedError {
            print(error.errorDescription ?? "Error description not provided")
        } catch {
            // For development purpose. We want to cache all of them
            print("Error not handled \(error.localizedDescription)")
        }
    }
}
