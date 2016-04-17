//
//  Utilities.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/22/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kStatusBarHeight: CGFloat = 20
let kTabBarHeight: CGFloat = 49

class Utilities {}

// MARK: - Search Button
protocol SearchPresenterDelegate: NSObjectProtocol {
  func presentSearchViewController()
}

extension Utilities {
  class func subviewsOfView(view: UIView, withType type: String) -> [UIView]
  {
    let prefix = "<\(type)"
    var subviewArray = view.subviews.flatMap { subview in subviewsOfView(subview, withType: type) }

    if view.description.hasPrefix(prefix) {
      subviewArray.append(view)
    }
    
    return subviewArray
  }
  
//  class func addSearchButtonToNavigationController(navigationItem: UINavigationItem, searchPresenter: SearchPresenterDelegate)
//  {
//    let existingButtons: [UIBarButtonItem]
//    if let rightButtons = navigationItem.rightBarButtonItems {
//      existingButtons = rightButtons
//    } else if let rightButton = navigationItem.rightBarButtonItem {
//      existingButtons = [rightButton]
//    } else {
//      existingButtons = []
//    }
//    
//    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: searchPresenter, action: "presentSearchViewController")
//    navigationItem.rightBarButtonItems = existingButtons + [searchButton]
//  }
}

// MARK: - Buffering Alert
extension Utilities {
  class func showLoadingAlert(title: String, onViewController vc: UIViewController?) -> SCLAlertView
  {
    let alert = SCLAlertView()
    alert.customViewColor = .secondaryColor
    
    if vc == nil {
      alert.showWaiting(title, subTitle: nil, closeButtonTitle: nil, duration: 0)
    }
    else {
      alert.showWaiting(vc, title: title, subTitle: nil, closeButtonTitle: nil, duration: 0)
    }
    
    return alert
  }
}

// MARK: - UIView Extensions
extension UIView {
  class func rectWithinBars(navigationBar navigationBar: Bool = true, tabBar: Bool = true) -> CGRect
  {
    let screenSize = UIScreen.mainScreen().bounds
    let yOffset: CGFloat = kStatusBarHeight + (navigationBar ? 44 : 0)
    let height = screenSize.height - yOffset - kMusicPlayerContractedHeight
    
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
  
  func contains(element: Array.Generator.Element) -> Bool
  {
    return contains { $0 == element }
  }
  
  func filterDownVotes() -> [Track]
  {
    let downvotes = UserPreferences.downvotes
    return filter { !downvotes.contains($0) }
  }
}


// MARK: - Delay
func delay(queue: dispatch_queue_t = dispatch_get_main_queue(), delay: Double, block:() -> Void)
{
  let goTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
  dispatch_after(goTime, queue, block)
}