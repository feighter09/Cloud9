//
//  ViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/6/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

extension UIColor {
  static var detailColor: UIColor { return UIColor.fromHex("#FF5E3A") }
  static var lightDetailColor: UIColor { return UIColor.fromHex("#FF2A68") }
  static var backgroundColor: UIColor { return UIColor.fromHex("#2B2B2B") }
  static var lightBackgroundColor: UIColor { return UIColor.fromHex("#4A4A4A") }
}

extension UIColor {
  // Creates a UIColor from a Hex string.
  class func fromHex(hex: String) -> UIColor
  {
    var cString: String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
    
    if (cString.hasPrefix("#")) {
      cString = cString.substringFromIndex(advance(cString.startIndex, 1))
    }
    
    if cString.characters.count != 6 { return UIColor.grayColor() }
    
    let rString = cString.substringToIndex(advance(cString.startIndex, 2))
    let gString = cString.substringFromIndex(advance(cString.startIndex, 2)).substringToIndex(advance(cString.startIndex, 2))
    let bString = cString.substringFromIndex(advance(cString.startIndex, 4)).substringToIndex(advance(cString.startIndex, 2))
    
    var r: CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    NSScanner(string: rString).scanHexInt(&r)
    NSScanner(string: gString).scanHexInt(&g)
    NSScanner(string: bString).scanHexInt(&b)
    
    return UIColor(colorLiteralRed: Float(r) / 255.0, green: Float(g) / 255.0, blue: Float(b) / 255.0, alpha: Float(1))
  }
}