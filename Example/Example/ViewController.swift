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
            let userQuery = UserQuery(email: "javier@mobilejazz.com")
            let notificationId = "f43fb412-b8b2-47af-bf9b-61b92b5e9c20"
            let deviceToken = "abdcde12345"

            // Channel Notification
            let config = try MagicBell.shared.getConfig().get(userQuery).result.get()
            print("Channel for notifications --> \(config.channel)")

            // User preferences
            let userPreferences = try MagicBell.shared.getUserPreferences().get(userQuery).result.get()
            print("User preferences --> \(userPreferences)")

            if let categories = userPreferences.notificationPreferences?.categories {
                for key in categories.keys {
                    if let category = categories[key],
                       var inApp = category.inApp {
                        inApp.toggle()
                    }
                }
            }

            let userPreferencesUpdated = try MagicBell.shared.putUserPreferences().put(userPreferences, in: userQuery).result.get()
            print("New user preferences --> \(userPreferencesUpdated)")


            // Notification
            let notification = try MagicBell.shared.getNotificationDataSource().get(
                    NotificationQuery(notificationId: notificationId, userQuery: userQuery)
            ).result.get()
            print("Notification --> \(notification)")

            // Mark Notification as readed
            _ = try MagicBell.shared.getActionNotificationDataSource().put(nil,
                    in: NotificationActionQuery(action: .markAsRead,
                            notificationId: notificationId,
                            userQuery: userQuery)).result.get()
            let notificationReaded = try MagicBell.shared.getNotificationDataSource().get(NotificationQuery(notificationId: notificationId,
                    userQuery: userQuery)).result.get()
            print(notificationReaded)

            // Uncomment to delete a notification
//            _ = MagicBell.shared.getDeleteNotificationDataSource().delete(NotificationQuery(notificationId: notificationId,
//                                                                                            userQuery: userQuery))

            // Push subscription
            let pushSubscription = try MagicBell.shared.getPushSubscriptionDataSource().put(
                    PushSubscription(deviceToken: deviceToken, platform: "ios"),
                    in: RegisterPushSubscriptionQuery(user: userQuery)
            ).result.get()
            print("Push subscription --> \(pushSubscription)")

            // Uncomment to delete a device
//            _ = try MagicBell.shared.getDeletePushSubscriptionDataSource().delete(DeletePushSubscriptionQuery(user: userQuery,
//                                                                                                              deviceToken: deviceToken)
//            ).result.get()
        } catch let error as LocalizedError {
            print(error.errorDescription ?? "Error description not provided")
        } catch {
            // For development purpose. We want to cache all of them
            print("Error not handled \(error.localizedDescription)")
        }
    }
}
