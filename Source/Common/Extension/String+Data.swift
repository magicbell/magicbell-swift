//
//  String+Data.swift
//  MagicBell
//
//  Created by Javi on 16/12/21.
//

import Foundation

extension String {
    init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}
