//
//  Copyright 2017 Mobile Jazz SL
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http:// www.apache.org / licenses / LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

private let alphaMask: UInt32  = 0xFF000000
private let redMask: UInt32    = 0x00FF0000
private let greenMask: UInt32  = 0x0000FF00
private let blueMask: UInt32   = 0x000000FF

private let alphaShift: UInt32 = 24
private let redShift: UInt32   = 16
private let greenShift: UInt32 = 8
private let blueShift: UInt32  = 0

private let colorSize: CGFloat = 256.0

private let redLum: CGFloat    = 0.2989
private let greenLum: CGFloat  = 0.5870
private let blueLum: CGFloat   = 0.1140

public extension UIColor {

    convenience init(rgb value: UInt32) {
        let red = (CGFloat)((value & redMask) >> redShift)
        let green = (CGFloat)((value & greenMask) >> greenShift)
        let blue = (CGFloat)((value & blueMask) >> blueShift)
        self.init(red: red / colorSize, green: green / colorSize, blue: blue / colorSize, alpha: 1.0)
    }

    convenience init(rgba value: UInt32) {
        let red = (CGFloat)((value & redMask) >> redShift)
        let green = (CGFloat)((value & greenMask) >> greenShift)
        let blue = (CGFloat)((value & blueMask) >> blueShift)
        let alpha = (CGFloat)((value & alphaShift) >> alphaShift)
        self.init(red: red / colorSize, green: green / colorSize, blue: blue / colorSize, alpha: alpha / colorSize)
    }

    convenience init?(rgb string: String) {
        var value: UInt32 = 0
        let scanner = Scanner(string: string)
        if scanner.scanHexInt32(&value) {
            self.init(rgb: value)
        } else {
            return nil
        }
    }

    convenience init?(rgba string: String) {
        var value: UInt32 = 0
        let scanner = Scanner(string: string)
        if scanner.scanHexInt32(&value) {
            self.init(rgba: value)
        } else {
            return nil
        }
    }

    convenience init(red255: CGFloat, blue255: CGFloat, green255: CGFloat) {
        self.init(red: red255 / colorSize, green: blue255 / colorSize, blue: green255 / colorSize, alpha: 1.0)
    }

    convenience init(red255: CGFloat, blue255: CGFloat, green255: CGFloat, alpha255: CGFloat) {
        self.init(red: red255 / colorSize, green: blue255 / colorSize, blue: green255 / colorSize, alpha: alpha255 / colorSize)
    }

    var rgbValue: UInt32 {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            if count == 4 {
                let red = (UInt32)(round(components[0] * colorSize))
                let green = (UInt32)(round(components[1] * colorSize))
                let blue = (UInt32)(round(components[2] * colorSize))
                return (red << redShift) + (green << greenShift) + (blue << blueShift)
            } else if count == 2 {
                let gray = (UInt32)(round(components[0] * colorSize))
                return (gray << redShift) + (gray << greenShift) + (gray << blueShift)
            }
        }
        return 0
    }

    var rgbaValue: UInt32 {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            if count == 4 {
                let red = (UInt32)(round(components[0] * colorSize))
                let green = (UInt32)(round(components[1] * colorSize))
                let blue = (UInt32)(round(components[2] * colorSize))
                let alpha = (UInt32)(round(components[3] * colorSize))
                return (red << redShift) + (green << greenShift) + (blue << blueShift) + (alpha << alphaShift)
            } else if count == 2 {
                let gray = (UInt32)(round(components[0] * colorSize))
                let alpha = (UInt32)(round(components[1] * colorSize))
                return (gray << redShift) + (gray << greenShift) + (gray << blueShift) + (alpha << alphaShift)
            }
        }
        return 0
    }

    var rgbString: String {
        let value = rgbValue
        return String(format: "%2X", value)
    }

    var rgbaString: String {
        let value = rgbaValue
        return String(format: "%2X", value)
    }

    func toGray() -> UIColor {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            if count == 4 {
                let luminiscence = components[0] * redLum + components[1] * greenLum + components[2] * blueLum
                return UIColor(white: luminiscence, alpha: components[3])
            } else if count == 2 {
                return self
            }
        }
        return UIColor.gray
    }

    func withSaturation(saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturationUnused: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturationUnused, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    func withBrightness(brightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightnessUnused: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightnessUnused, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    func lighter(ratio: CGFloat) -> UIColor {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents

            let colorTransform: (CGFloat) -> CGFloat = { component in
                return component + (1.0 - component) * ratio
            }

            if count == 4 {
                let newComponents: [CGFloat] = [
                    colorTransform(components[0]),
                    colorTransform(components[1]),
                    colorTransform(components[2]),
                    components[3]
                ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: newComponents)!)
            } else if count == 2 {
                let newComponents: [CGFloat] = [
                    colorTransform(components[0]),
                    components[1]
                ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceGray(), components: newComponents)!)
            }
        }
        return self
    }

    func darker(ratio: CGFloat) -> UIColor {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents

            let colorTransform: (CGFloat) -> CGFloat = { component in
                return component * (1.0 - ratio)
            }

            if count == 4 {
                let newComponents: [CGFloat] = [
                    colorTransform(components[0]),
                    colorTransform(components[1]),
                    colorTransform(components[2]),
                    components[3]
                ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: newComponents)!)
            } else if count == 2 {
                let newComponents: [CGFloat] = [
                    colorTransform(components[0]),
                    components[1]
                ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceGray(), components: newComponents)!)
            }
        }
        return self
    }

    func isLightColor() -> Bool {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            if count == 4 {
                let luminiscence = components[0] * redLum + components[1] * greenLum + components[2] * blueLum
                return luminiscence > 0.8
            } else if count == 2 {
                return components[0] > 0.8
            }
        }
        return false
    }

    func isDarkColor() -> Bool {
        return !isLightColor()
    }
}
