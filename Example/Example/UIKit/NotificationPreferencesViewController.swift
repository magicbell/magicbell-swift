//
//  NotificationPreferencesViewController.swift
//  Example
//
//  Created by Ullrich Schäfer on 06.04.24.
//

import Foundation
import UIKit
import MagicBell

class NotificationPreferencesViewController: UITableViewController, NotificationChannelsViewControllerDelegate {
    
    // swiftlint:disable implicitly_unwrapped_optional
    var user: MagicBell.User!
    var preferences: MagicBell.NotificationPreferences? {
        didSet {
            if let channelsVC = channelsVC,
               let category = channelsVC.category
            {
                channelsVC.category = preferences?.categories.filter({ $0.slug == category.slug }).first
            }
            self.tableView.reloadData()
        }
    }
    
    weak var channelsVC: NotificationChannelsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user.preferences.fetch { result in
            switch result {
            case .failure(let error):
                print("Error fetching notification preferences: \(error)")
            case .success(let preferences):
                self.preferences = preferences
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "channels" {
            if let destinationVC = segue.destination as? NotificationChannelsViewController {
                
                self.channelsVC = destinationVC
                destinationVC.delegate = self
                
                if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                    destinationVC.category = self.preferences?.categories[indexPath.row]
                }
            }
        }
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.preferences?.categories.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
            fatalError("Could not dequeue table view cell with identifier \(reuseIdentifier)")
        }
        guard let category = self.preferences?.categories[indexPath.row] else { return cell }
        cell.textLabel?.text = category.label
        cell.detailTextLabel?.text = "\(category.channels.count)"
        return cell
    }
    
    // MARK: - NotificationChannelsViewControllerDelegate
    
    func updateChannel(_ sender: NotificationChannelsViewController, categorySlug: String, channelSlug: String, enabled: Bool) {
        user.preferences.update(categorySlug: categorySlug, channelSlug: channelSlug, enabled: enabled) { result in
            switch result {
            case .failure(let error):
                print("Error fetching notification preferences: \(error)")
            case .success(let preferences):
                self.preferences = preferences
            }
        }
    }
}
