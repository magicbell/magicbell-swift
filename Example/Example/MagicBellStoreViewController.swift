//
//  MagicBellStoreViewController.swift
//  Example
//
//  Created by Javi on 17/11/21.
//

import UIKit
import MagicBell

class MagicBellStoreViewController: UIViewController, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!

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
    }

    @objc private func refreshAction(sender: UIRefreshControl) {
        print("Refresh")
        sender.endRefreshing()
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
            print("Mark All Read")
        })

        alert.addAction(UIAlertAction(title: "Mark All Seen", style: .default) { _ in
            print("Mark All Seen")
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
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MagicBellStoreCell", for: indexPath) as? MagicBellStoreCell else {
            fatalError("Couldn't dequeue a MagicBellStoreCell")
        }

        cell.titleLabel.text = "My Notification"

        cell.accessoryView = unreadBadgeView()

        // swiftlint:disable:next line_length
        cell.bodyLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."

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

        let alert = UIAlertController(title: "Notification Title", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Archive", style: .default) { _ in
            print("Archive")
        })

        alert.addAction(UIAlertAction(title: "Unarchive", style: .default) { _ in
            print("Unarchive")
        })

        alert.addAction(UIAlertAction(title: "Mark Read", style: .default) { _ in
            print("Mark Read")
        })

        alert.addAction(UIAlertAction(title: "Mark Unread", style: .default) { _ in
            print("Mark Unread")
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("Delete")
        })

        present(alert, animated: true, completion: nil)
    }
}
