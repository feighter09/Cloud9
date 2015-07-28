//
//  Utilities.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/22/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class Utilities {

}

// MARK: - UIView Extensions
extension UIView {
  class func rectWithinBars(navigationBar: Bool = true, tabBar: Bool = true) -> CGRect
  {
    let screenSize = UIScreen.mainScreen().bounds
    let yOffset: CGFloat = navigationBar ? 64 : 0
    let height = screenSize.height - yOffset - (tabBar ? 49 : 0)
    
    return CGRect(x: 0, y: yOffset, width: screenSize.width, height: height)
  }
}

// MARK: - Array Extensions
extension Array where Element: Track {
  func uniqueElements() -> [Track]
  {
    return self.reduce([], combine: { (uniques, element) -> [Track] in
      uniques.contains { element == $0 } ? uniques : uniques + [element]
    })
  }
}

