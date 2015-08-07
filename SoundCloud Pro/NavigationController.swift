//
//  NavigationController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/7/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
  
  override func viewDidLayoutSubviews()
  {
    super.viewDidLayoutSubviews()

    view.frame = UIView.rectWithinBars()
    view.layoutIfNeeded()
  }
}
