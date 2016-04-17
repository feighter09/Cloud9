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
  private var player = MusicPlayerViewController.sharedPlayer
}

// MARK: - View Life Cycle
extension TabBarController {
  override func viewDidLoad()
  {
    super.viewDidLoad()

//    repositionTabBar()
    addPlayer()
    tabBar.tintColor = .secondaryColor
    
    tabBar.backgroundColor = .backgroundColor
  }
  
  private func repositionTabBar()
  {
    let tabBarHeight = tabBar.bounds.height
    let dy = -(UIScreen.mainScreen().bounds.height - tabBarHeight)
    tabBar.frame.offsetInPlace(dx: 0, dy: dy)
  }
  
  private func addPlayer()
  {
    let yOffset = UIScreen.mainScreen().bounds.height - kMusicPlayerContractedHeight - tabBar.bounds.height
    let width = UIScreen.mainScreen().bounds.width
    player.view.frame = CGRect(x: 0, y: yOffset, width: width, height: kMusicPlayerContractedHeight)
    view.addSubview(player.view)
    
    player.didMoveToParentViewController(self)
    player.setValue(self, forKey: "parentViewController") // such a hack, didMoveToParentViewController doesn't set parentVC
  }
}
