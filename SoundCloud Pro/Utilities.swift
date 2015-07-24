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

// MARK: - Array Extensions
extension Array where Element: Track {
  func uniqueElements() -> [Track]
  {
    return self.reduce([], combine: { (uniques, element) -> [Track] in
      uniques.contains { element == $0 } ? uniques : uniques + [element]
    })
  }
}

