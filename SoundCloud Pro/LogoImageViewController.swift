//
//  LogoImageViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/17/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class LogoImageViewController: UIViewController {
  
  override func viewDidLoad()
  {
    super.viewDidLoad()

    navigationItem.titleView = UIImageView(image: UIImage(named: "cloud9LogoRedWhite")!)
  }
}
