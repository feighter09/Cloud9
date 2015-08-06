//
//  PlayPauseButton.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/12/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class PlayPauseButton: UIButton, Listener {
  var listenerId = 0
  var playState: PlayState = .Paused {
    didSet { updateImage() }
  }
  
  private var bufferingView: UIActivityIndicatorView!
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    makeCircular()
    updateImage()
  }
}

// MARK: - Helpers
extension PlayPauseButton {
  private func makeCircular()
  {
    layer.cornerRadius = CGRectGetWidth(bounds) / 2
  }
  
  private func updateImage()
  {
    switch playState {
      case .Playing:
        fallthrough
      case .Paused:
        removeBufferingView()
        setImage(playState.image, forState: .Normal)
      case .Buffering:
        addBufferingView()
      case .Stopped:
        break
    }
  }
  
  private func addBufferingView()
  {
    if bufferingView == nil {
      bufferingView = UIActivityIndicatorView(frame: bounds)
      addSubview(bufferingView)
    }
    
    setImage(nil, forState: .Normal)
    bufferingView.startAnimating()
    bufferingView.hidden = false
  }

  private func removeBufferingView()
  {
    bufferingView?.stopAnimating()
    bufferingView?.hidden = true
  }
}
