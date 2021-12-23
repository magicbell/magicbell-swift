//
//  MagicBellStoreViewController.swift
//  Example
//
//  Created by Javi on 17/11/21.
//

import UIKit
import MagicBell

// swiftlint:disable line_length
class MagicBellStoreViewController: UIViewController, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource, NotificationStoreContentObserver, NotificationStoreCountObserver {

    private var isLoadingNextPage = false

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var magicBellStoreItem: BadgeBarButtonItem!

    private var userBell = magicBell.forUser(email: "magicbell@mobilejazz.com")
    private lazy var store = userBell.store.forAll()

    private var observer: AnyObject?

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

        reloadStore()

        store.addContentObserver(self)
        store.addCountObserver(self)
    }

    // swiftlint:disable empty_count
    private func reloadStore() {
        if store.count == 0 {
            store.refresh { result in
                switch result {
                case .success:
                    // Observers will manage changes
                    break
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            tableView.reloadData()
            magicBellStoreItem.badgeNumber = store.unseenCount
        }
    }

    @objc private func refreshAction(sender: UIRefreshControl) {
        store.refresh { result in
            sender.endRefreshing()
            switch result {
            case .success:
                // Observers will manage changes
                break
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

    @IBAction func menuAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
            let alert = UIAlertController(title: "Login", message: "Insert user's email", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "john@doe.com"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
                guard let email = alert.textFields?.first?.text else {
                    return
                }
                self.userBell = magicBell.forUser(email: email)
                self.configureStore(predicate: StorePredicate())
            })
            self.present(alert, animated: true, completion: nil)
        })

        alert.addAction(UIAlertAction(title: "Customize Predicate", style: .default) { _ in
            let alert = UIAlertController(title: "Customize Predicate", message: nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "All Notifications", style: .default) { _ in
                self.configureStore(predicate: StorePredicate())
            })
            alert.addAction(UIAlertAction(title: "Only Read", style: .default) { _ in
                self.configureStore(predicate: StorePredicate(read: .read))
            })
            alert.addAction(UIAlertAction(title: "Only Unread", style: .default) { _ in
                self.configureStore(predicate: StorePredicate(read: .unread))
            })
            alert.addAction(UIAlertAction(title: "By Category", style: .default) { _ in
                self.configureStore(predicate: StorePredicate(categories: ["order_created"]))
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    private func configureStore(predicate: StorePredicate) {
        store.removeContentObserver(self)
        store.removeCountObserver(self)

        store = userBell.store.with(predicate: predicate)
        store.addContentObserver(self)
        store.addCountObserver(self)

        reloadStore()
    }

    @IBAction func globalAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Mark All Read", style: .default) { _ in
            self.store.markAllRead { error in
                if error != nil {
                    print("Action not completed")
                }
                self.tableView.reloadData()
            }
        })

        alert.addAction(UIAlertAction(title: "Mark All Seen", style: .default) { _ in
            self.store.markAllSeen { error in
                if error != nil {
                    print("Action not completed")
                }
                self.tableView.reloadData()
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
        return store.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MagicBellStoreCell", for: indexPath) as? MagicBellStoreCell else {
            fatalError("Couldn't dequeue a MagicBellStoreCell")
        }

        let notification = store[indexPath.row]

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

        let notification = store[indexPath.row]

        let alert = UIAlertController(title: "Notification Title", message: nil, preferredStyle: .actionSheet)

        if notification.archivedAt == nil {
            alert.addAction(UIAlertAction(title: "Archive", style: .default) { _ in
                self.store.archive(notification) { error in
                    if error == nil {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            })
        } else {
            alert.addAction(UIAlertAction(title: "Unarchive", style: .default) { _ in
                self.store.unarchive(notification) { error in
                    if error == nil {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            })
        }

        if notification.readAt == nil {
            alert.addAction(UIAlertAction(title: "Mark Read", style: .default) { _ in
                self.store.markAsRead(notification) { error in
                    if error == nil {
                        if let cell = self.tableView.cellForRow(at: indexPath) {
                            if notification.readAt == nil {
                                cell.accessoryView = self.unreadBadgeView()
                            } else {
                                cell.accessoryView = nil
                            }
                        }
                    }
                }
            })
        } else {
            alert.addAction(UIAlertAction(title: "Mark Unread", style: .default) { _ in
                self.store.markAsUnread(notification) { error in
                    if error == nil {
                        if let cell = self.tableView.cellForRow(at: indexPath) {
                            if notification.readAt == nil {
                                cell.accessoryView = self.unreadBadgeView()
                            } else {
                                cell.accessoryView = nil
                            }
                        }
                    }
                }
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.store.delete(notification) { _ in
                // Nothing to be done here. If deletion is successful, observer will notify the deletion
            }
        })

        present(alert, animated: true, completion: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLoadingNextPage &&
            (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height - 200) && store.hasNextPage {
            isLoadingNextPage = true
            print("Load next page")
            store.fetch { result in
                print("Load completed")
                self.isLoadingNextPage = false
                switch result {
                case .success(let notifications):
                    // Observers will manage changes
                    break
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    // MARK: NotificationStoreContentDelegate

    func didReloadStore(_ store: NotificationStore) {
        self.tableView.reloadData()
    }

    func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int]) {
        self.tableView.reloadRows(at: indexes.map { idx in
            IndexPath(row: idx, section: 0)
        }, with: .none)
    }

    func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int]) {
        self.tableView.deleteRows(at: indexes.map { idx in
            IndexPath(row: idx, section: 0)
        }, with: .fade)
    }

    func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int]) {
        self.tableView.insertRows(at: indexes.map { idx in
            IndexPath(row: idx, section: 0)
        }, with: .fade)
    }

    // MARK: NotificationStoreCountDelegate

    func store(_ store: NotificationStore, didChangeTotalCount count: Int) {
        title = "Notifications - \(count)"
    }

    func store(_ store: NotificationStore, didChangeUnreadCount count: Int) {
        print("Unread notification - \(count)")
    }

    func store(_ store: NotificationStore, didChangeUnseenCount count: Int) {
        magicBellStoreItem.badgeNumber = count
    }
}
