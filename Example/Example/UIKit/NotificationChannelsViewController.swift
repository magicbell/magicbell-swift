//
//  NotificationChannelsViewController.swift
//  Example
//
//  Created by Ullrich Schäfer on 07.04.24.
//

import Foundation
import UIKit
import MagicBell

class NotificationChannelsViewController: UITableViewController {
    // swiftlint:disable implicitly_unwrapped_optional
    var category: MagicBell.Category!
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.channels.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
            fatalError("Could not dequeue table view cell with identifier \(reuseIdentifier)")
        }
        guard let channel = category?.channels[indexPath.row] else { return cell }
        cell.textLabel?.text = channel.label
        cell.detailTextLabel?.text = "\(channel.enabled)"
        return cell
    }
}
