//
//  IntMotherObject.swift
//  MagicBell
//
//  Created by Javi on 28/1/22.
//

import Foundation

func anyInt(minValue: Int = -32000, maxValue: Int = 32000) -> Int {
    return Int.random(in: minValue...maxValue)
}
