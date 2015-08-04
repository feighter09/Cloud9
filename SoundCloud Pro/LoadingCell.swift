//
//  LoadingCell.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/30/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
  @IBOutlet private weak var spinner: UIActivityIndicatorView!
}

// MARK: - Interface
extension LoadingCell {
  func animate()
  {
    spinner.startAnimating()
  }
}