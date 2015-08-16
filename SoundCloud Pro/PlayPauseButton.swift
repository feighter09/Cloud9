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
  
  private lazy var bufferingView: UIActivityIndicatorView = {
    let bufferingView = UIActivityIndicatorView(frame: self.bounds)
    bufferingView.color = .detailColor
    self.addSubview(bufferingView)
    return bufferingView
  }()
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    setColors()
    makeCircular()
    updateImage()
  }
}

// MARK: - Helpers
extension PlayPauseButton {
  private func setColors()
  {
    tintColor = .detailColor
  }
  
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
        removeBufferingView()
        setImage(playState.image, forState: .Normal)
    }
  }
  
  private func addBufferingView()
  {
    setImage(nil, forState: .Normal)
    bufferingView.startAnimating()
    bufferingView.hidden = false
  }

  private func removeBufferingView()
  {
    bufferingView.stopAnimating()
    bufferingView.hidden = true
  }
}
