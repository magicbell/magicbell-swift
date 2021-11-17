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
            let string = try TryPod(param: "Param", superLongParam: "SuperLongParam").future.result.get()
            print(string)
        } catch {
            print(error.localizedDescription)
        }
    }
}
