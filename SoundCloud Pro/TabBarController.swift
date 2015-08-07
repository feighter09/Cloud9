//
//  TabBarController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/6/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
  private var player = MusicPlayerViewController.instanceFromNib()
}

// MARK: - View Life Cycle
extension TabBarController {
  override func viewDidLoad()
  {
    super.viewDidLoad()

    repositionTabBar()
    addPlayer()
  }
  
  private func repositionTabBar()
  {
    let navHeight: CGFloat = 64
    let tabBarHeight = tabBar.bounds.height
    let dy = -(UIScreen.mainScreen().bounds.height - navHeight - tabBarHeight)
    tabBar.frame.offset(dx: 0, dy: dy)
  }
  
  private func addPlayer()
  {
    let height: CGFloat = 100
    let yOffset = UIScreen.mainScreen().bounds.height - height
    let width = UIScreen.mainScreen().bounds.width
    player.view.frame = CGRect(x: 0, y: yOffset, width: width, height: height)
    view.addSubview(player.view)
  }
}

// MARK: - Slide Navigation Delegate
extension TabBarController: SlideNavigationControllerDelegate {
  func slideNavigationControllerShouldDisplayLeftMenu() -> Bool
  {
    return true
  }
}
