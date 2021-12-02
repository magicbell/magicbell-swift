//
//  MagicBellStoreViewController.swift
//  Example
//
//  Created by Javi on 17/11/21.
//

import UIKit
import MagicBell
import struct MagicBell.Notification

class MagicBellStoreViewController: UIViewController, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource {

    private var isLoadingNextPage = false

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!

    private var notificationStore: NotificationStore = MagicBell.createStore(name: "Main", predicate: StorePredicate(read: .unread))
    private var notifications: [Notification] = []

    var navigationBarColor = UIColor(rgb: 0x6113A3) {
        didSet { applyBarStyle() }
    }
    var navigationBarTitleColor = UIColor.white {
        didSet { applyBarStyle() }
    }
    override var title: String? {
        didSet { navigationBar.topItem?.title = title }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Notifications"

        navigationBar.topItem?.title = self.title
        applyBarStyle()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        notificationStore.fetch { result in
            switch result {
            case .success(let notifications):
                self.notifications.append(contentsOf: notifications)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc private func refreshAction(sender: UIRefreshControl) {
        notificationStore.fetch(refresh: true) { result in
            sender.endRefreshing()
            switch result {
            case .success(let notifications):
                self.notifications.removeAll()
                self.notifications.append(contentsOf: notifications)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func applyBarStyle() {
        navigationBar.tintColor = navigationBarTitleColor
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navigationBarColor
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: navigationBarTitleColor // nav text color
            ]
            navigationBar?.standardAppearance = appearance
            navigationBar?.scrollEdgeAppearance = UINavigationBar.appearance().standardAppearance
        } else {
            navigationBar?.barTintColor = navigationBarColor
            navigationBar?.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: navigationBarTitleColor  // nav text color
            ]
        }
    }

    @IBAction func globalAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Mark All Read", style: .default) { _ in
            self.notificationStore.markAllNotificationsAsRead { error in
                if error != nil {
                    print("Action not completed")
                }
            }
        })

        alert.addAction(UIAlertAction(title: "Mark All Seen", style: .default) { _ in
            self.notificationStore.markAllNotificationsAsSeen { error in
                if error != nil {
                    print("Action not completed")
                }
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    // MARK: UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MagicBellStoreCell", for: indexPath) as? MagicBellStoreCell else {
            fatalError("Couldn't dequeue a MagicBellStoreCell")
        }

        let notification = notifications[indexPath.row]

        cell.titleLabel.text = notification.title
        cell.bodyLabel.text = notification.content

        if notification.readAt == nil {
            cell.accessoryView = unreadBadgeView()
        } else {
            cell.accessoryView = nil
        }

        return cell
    }

    private func unreadBadgeView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        view.clipsToBounds = true
        view.layer.cornerRadius = 3
        view.backgroundColor = navigationBarColor
        view.isUserInteractionEnabled = false
        return view
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let notification = notificationStore.notifications[indexPath.row]

        let alert = UIAlertController(title: "Notification Title", message: nil, preferredStyle: .actionSheet)

        if notification.archivedAt == nil {
            alert.addAction(UIAlertAction(title: "Archive", style: .default) { _ in
                self.notificationStore.markNotificationAsArchived(notification) { error in
                    if error != nil {
                        print("Action not completed")
                    }
                }
            })
        } else {
            alert.addAction(UIAlertAction(title: "Unarchive", style: .default) { _ in
                self.notificationStore.markNotificationAsUnarchived(notification) { error in
                    if error != nil {
                        print("Action not completed")
                    }
                }
            })
        }

        if notification.readAt == nil {

            alert.addAction(UIAlertAction(title: "Mark Read", style: .default) { _ in
                self.notificationStore.markNotificationAsRead(notification) { error in
                    if error != nil {
                        print("Action not completed")
                    }
                }
            })
        } else {
            alert.addAction(UIAlertAction(title: "Mark Unread", style: .default) { _ in
                self.notificationStore.markNotificationAsUnread(notification) { error in
                    if error != nil {
                        print("Action not completed")
                    }
                }
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.notificationStore.removeNotification(notification) { error in
                if error != nil {
                    print("Action not completed")
                }
            }
        })

        present(alert, animated: true, completion: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLoadingNextPage &&
            (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height - 200) &&
            notificationStore.hasNextPage {
            isLoadingNextPage = true
            print("Load next page")
            notificationStore.fetch { result in
                print("Load completed")
                self.isLoadingNextPage = false
                switch result {
                case .success(let notifications):
                    self.notifications.append(contentsOf: notifications)
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
