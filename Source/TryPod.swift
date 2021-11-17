//
//  TryPod.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

public class TryPod {

    private let param: String
    private let superLongParam: String

    public init(param: String,
                superLongParam: String) {
        self.param = param
        self.superLongParam = superLongParam
    }
    
    public let future = Future("It works :)")
}
