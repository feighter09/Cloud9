//
//  TabBarController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/6/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

enum Tabs: String {
  case Stream, Playlists
}

class TabBarController: UITabBarController {
  private var player = MusicPlayerViewController.instanceFromNib()
  
  private var hamburgerButton: UIBarButtonItem!
//  private var backButton:
}

// MARK: - View Life Cycle
extension TabBarController {
  override func viewDidLoad()
  {
    super.viewDidLoad()

    repositionTabBar()
    addPlayer()
//    setupSlideMenu()
  }
  
  private func repositionTabBar()
  {
    let tabBarHeight = tabBar.bounds.height
    let dy = -(UIScreen.mainScreen().bounds.height - tabBarHeight)
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
  
  private func setupSlideMenu()
  {
    hamburgerButton = UIBarButtonItem(image: UIImage(named: "menu-button")!,
                                      style: .Plain,
                                      target: SlideNavigationController.sharedInstance(),
                                      action: "toggleLeftMenu")
    SlideNavigationController.sharedInstance().leftBarButtonItem = hamburgerButton
  }
}

// MARK: - Slide Navigation Delegate
extension TabBarController {
  
//  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem)
//  {
//    switch Tabs(rawValue: item.title!)! {
//    case .Stream:
//      SlideNavigationController.sharedInstance().leftBarButtonItem = hamburgerButton
//    case .Playlists:
//      break
//    }
//  }
}

// MARK: - Slide Navigation Delegate
extension TabBarController: SlideNavigationControllerDelegate {
  func slideNavigationControllerShouldDisplayLeftMenu() -> Bool
  {
    return true
  }
}
