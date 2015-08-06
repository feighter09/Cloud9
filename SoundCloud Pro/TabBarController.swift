//
//  TabBarController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/6/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad()
    {
      super.viewDidLoad()
      let navHeight: CGFloat = 64
      let tabBarHeight = tabBar.bounds.height
      let dy = -(UIScreen.mainScreen().bounds.height - navHeight - tabBarHeight)
      tabBar.frame.offset(dx: 0, dy: dy)
    }
}
