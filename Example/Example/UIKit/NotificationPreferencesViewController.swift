//
//  NotificationPreferencesViewController.swift
//  Example
//
//  Created by Ullrich Schäfer on 06.04.24.
//

import Foundation
import UIKit
import MagicBell

class NotificationPreferencesViewController: UITableViewController {
    
    // swiftlint:disable implicitly_unwrapped_optional
    var user: MagicBell.User!
    var categories: [MagicBell.Category]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user.preferences.fetch { result in
            switch result {
            case .failure(let error):
                print("Error fetching notification preferences: \(error)")
            case .success(let preferences):
                self.categories = preferences.categories
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "channels" {
            if let destinationVC = segue.destination as? NotificationChannelsViewController {
                if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                    destinationVC.category = self.categories![indexPath.row]
                }
            }
        }
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count \(categories?.count)")
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
            fatalError("Could not dequeue table view cell with identifier \(reuseIdentifier)")
        }
        guard let category = categories?[indexPath.row] else { return cell }
        cell.textLabel?.text = category.label
        cell.detailTextLabel?.text = "\(category.channels.count)"
        return cell
    }
}
