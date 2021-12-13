//
//  LoggerFactory.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Foundation
import Harmony

public enum LogLevel {
    case none
    case debug

    func obtainLogger() -> Logger {
        switch self {
        case .none:
            return VoidLogger()
        case .debug:
            return DeviceConsoleLogger()
        }
    }
}
