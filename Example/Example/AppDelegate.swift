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

import UIKit
import MagicBell
import UserNotifications

extension MagicBellClient {
    /// Application global instance of MagicBellClient
    static var shared = MagicBellClient(
        apiKey: "34ed17a8482e44c765d9e163015a8d586f0b3383",
        logLevel: .debug
    )
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Registering for push notification
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
                        if let error = error {
                            print("Request Authorization Failed (\(error), \(error.localizedDescription))")
                        }
                        if granted {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    //
                } else if settings.authorizationStatus == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Request Authorization Failed (\(error), \(error.localizedDescription))")
    }


    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Storing device token when refreshed
        MagicBellClient.shared.setDeviceToken(deviceToken: deviceToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("Clicked on Push notification")
        print(response.notification.request.content.userInfo)
        
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        let title = userInfo.value(forKeyPath: "aps.alert.title") as? String ?? "Sent without title"
        let body = userInfo.value(forKeyPath: "aps.alert.body") as? String ?? "Sent without body"
        let alert = UIAlertController(title: "Notification opened",
                                      message: "\(title)\n\(body)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last?.rootViewController?.present(alert, animated: true)
    }
}
