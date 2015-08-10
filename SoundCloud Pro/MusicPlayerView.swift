//
//  MusicPlayerView.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/10/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class MusicPlayerView: UIView {
  @IBOutlet private weak var expandContractButton: UIButton!
  
  override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
  {
    if let view = super.hitTest(point, withEvent: event) { return view }
    else if CGRectContainsPoint(expandContractButton.frame, point) { return expandContractButton }

    return nil
  }
}
