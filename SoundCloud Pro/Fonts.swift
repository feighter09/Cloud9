//
//  Fonts.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/16/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

// MARK: - Swizzling
extension UIFont {
  class var defaultFontFamily: String { return "Georgia" }
  
//  override public class func initialize()
//  {
//    if self == UIFont.self {
//      swizzleSystemFont()
//    }
//  }
  
  class func setNewDefaultFont()
  {
    swizzleSystemFont()
    UILabel.appearance().substituteFontFamily = defaultFontFamily
  }
  
  private class func swizzleSystemFont()
  {
    let systemPreferredFontMethod = class_getClassMethod(self, "preferredFontForTextStyle:")
    let mySystemPreferredFontMethod = class_getClassMethod(self, "myPreferredFontForTextStyle:")
    method_exchangeImplementations(systemPreferredFontMethod, mySystemPreferredFontMethod)
    
    let systemFontMethod = class_getClassMethod(self, "systemFontOfSize:")
    let mySystemFontMethod = class_getClassMethod(self, "mySystemFontOfSize:")
    method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
    
    let boldSystemFontMethod = class_getClassMethod(self, "boldSystemFontOfSize:")
    let myBoldSystemFontMethod = class_getClassMethod(self, "myBoldSystemFontOfSize:")
    method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
    
    let italicSystemFontMethod = class_getClassMethod(self, "italicSystemFontOfSize:")
    let myItalicSystemFontMethod = class_getClassMethod(self, "myItalicSystemFontOfSize:")
    method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
  }
}

// MARK: - New Font Methods
extension UIFont {
  private class func myPreferredFontForTextStyle(style: String) -> UIFont
  {
    let defaultFont = myPreferredFontForTextStyle(style)  // will not cause stack overflow - this is now the old, default UIFont.preferredFontForTextStyle
    let newDescriptor = defaultFont.fontDescriptor().fontDescriptorWithFamily(defaultFontFamily)
    return UIFont(descriptor: newDescriptor, size: defaultFont.pointSize)
  }
  
  private class func mySystemFontOfSize(fontSize: CGFloat) -> UIFont
  {
    return myDefaultFontOfSize(fontSize)
  }
  
  private class func myBoldSystemFontOfSize(fontSize: CGFloat) -> UIFont
  {
    return myDefaultFontOfSize(fontSize, withTraits: .TraitBold)
  }
  
  private class func myItalicSystemFontOfSize(fontSize: CGFloat) -> UIFont
  {
    return myDefaultFontOfSize(fontSize, withTraits: .TraitItalic)
  }
  
  private class func myDefaultFontOfSize(fontSize: CGFloat, withTraits traits: UIFontDescriptorSymbolicTraits = []) -> UIFont
  {
    let descriptor = UIFontDescriptor(name: defaultFontFamily, size: fontSize).fontDescriptorWithSymbolicTraits(traits)
    return UIFont(descriptor: descriptor, size: fontSize)
  }
}

extension UILabel {
  
  var substituteFontFamily: String {
    get { return self.font.fontName }
    set { setFontWithFamily(newValue) }
  }
  
  private func setFontWithFamily(fontFamily: String)
  {
    let newDescriptor = font.fontDescriptor().fontDescriptorWithFamily(fontFamily)
    NSLog("previous font: \(font), new font: \(newDescriptor)")
    font = UIFont(descriptor: newDescriptor, size: font.pointSize)
//    addObserver(self, forKeyPath: "font", options: [.New, .Old], context: nil)
//    swizzleDeinit()
  }
  
  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    let old = change?[NSKeyValueChangeOldKey]!
    let new = change?[NSKeyValueChangeNewKey]!
    NSLog("\(keyPath) changed from \(old) to \(new)")
  }
  
  private func swizzleDeinit()
  {
    let defaultDeinit = class_getInstanceMethod(self.classForCoder, "deinit")
    let myDeinit = class_getInstanceMethod(self.classForCoder, "myDeinit")
    method_exchangeImplementations(defaultDeinit, myDeinit)
  }
  
  private func myDeinit()
  {
    removeObserver(self, forKeyPath: "font")
  }
}