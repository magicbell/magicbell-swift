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

            let userQueryFactory: () -> UserQuery = { UserQuery(email: "javier@mobilejazz.com") }
            let notificationId = "f43fb412-b8b2-47af-bf9b-61b92b5e9c20"
            let deviceToken = "abdcde12345"

//            // Channel Notification
//            let getConfigNetworkDataSource = MagicBell.shared.sdkProvider.configComponent.getConfigNetworkDataSource()
//            let config = try getConfigNetworkDataSource.get(userQuery).result.get()
//            print("Channel for notifications --> \(config.channel)")

            let config = try MagicBell.shared.sdkProvider.userConfigComponent.getUserConfigInteractor()
                .execute(refresh: true, userQuery: userQueryFactory()).result.get()
            print("Channel for notifications --> \(config.channel)")
            _ = MagicBell.shared.sdkProvider.userConfigComponent.deleteUserConfigInteractor().execute(userQuery: userQueryFactory())
            print("Removed config for user --> \(userQueryFactory().key)")
            // User preferences
            let getUserPreferencesNetworkDataSource = MagicBell.shared.sdkProvider.userPreferencesComponent.getUserPreferencesNetworkDataSource()
            let userPreferences = try getUserPreferencesNetworkDataSource.get(userQueryFactory()).result.get()
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
            let userPreferencesUpdated = try getPutUserPreferenceNetworkDataSource.put(userPreferences, in: userQueryFactory()).result.get()
            print("New user preferences --> \(userPreferencesUpdated)")


            // Notification

            let notificationDataSource = MagicBell.shared.sdkProvider.notificationComponent.getNotificationNetworkDataSource()
            let actionNotificationDataSource = MagicBell.shared.sdkProvider.notificationComponent.getActionNotificationNetworkDataSource()

            let notification = try notificationDataSource.get(NotificationQuery(notificationId: notificationId, userQuery: userQueryFactory())).result.get()
            print("Notification --> \(notification)")

            // Mark Notification as readed
            _ = try actionNotificationDataSource.put(nil, in: NotificationActionQuery(action: .markAsRead,
                                                      notificationId: notificationId,
                                                      userQuery: userQueryFactory())).result.get()
            let notificationReaded = try notificationDataSource.get(NotificationQuery(notificationId: notificationId,
                                                                                      userQuery: userQueryFactory())).result.get()
            print(notificationReaded)

            // Uncomment to delete a notification
            // let deleteNotificationDataSource = MagicBell.shared.sdkProvider.notificationComponent.getDeleteNotificationNetworkDataSource()
            // _ = deleteNotificationDataSource.delete(NotificationQuery(notificationId: notificationId, userQuery: userQuery))

            // Push subscription
            let getPushSubscriptionNetworkDataSource = MagicBell.shared.sdkProvider.pushSubscriptionComponent.getPushSubscriptionNetworkDataSource()
            let pushSubscription = try getPushSubscriptionNetworkDataSource.put(
                PushSubscription(deviceToken: deviceToken),
                in: userQueryFactory()
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
