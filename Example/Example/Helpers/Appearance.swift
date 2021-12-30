//
//  Appearance.swift
//  Example
//
//  Created by Joan Martin on 28/12/21.
//

import Foundation
import UIKit

extension UIColor {
    static let magicBell = UIColor(rgb: 0x6113A3)
}


enum Appearance {
    static func apply() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .magicBell
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white // nav text color
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBar.appearance().standardAppearance
        UINavigationBar.appearance().tintColor = .white
    }
}
