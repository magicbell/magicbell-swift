//
//  UIHostingViewController.swift
//  Example
//
//  Created by Joan Martin on 28/12/21.
//

import Foundation
import UIKit
import SwiftUI

class HostingController<ContentView>: UIHostingController<ContentView> where ContentView : View {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
