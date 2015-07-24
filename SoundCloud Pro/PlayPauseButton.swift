//
//  PlayPauseButton.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/12/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

enum PlayPauseState: String {
  case Play = "Play"
  case Pause = "Pause"
  case Loading = "Loading"
  
  var image: UIImage! {
    switch self {
    case .Play: return UIImage(named: "Pause")
    case .Pause: return UIImage(named: "Play")
    case .Loading: return nil
    }
  }
}

class PlayPauseButton: UIButton, Listener {
  var listenerId = 0
  var playState: PlayPauseState = .Pause {
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
      case .Play:
        fallthrough
      case .Pause:
        removeBufferingView()
        setImage(playState.image, forState: .Normal)
      case .Loading:
        addBufferingView()
    }
  }
  
  private func addBufferingView()
  {
    if bufferingView == nil {
      NSLog("frame: \(frame), bounds: \(bounds), center: \(center)")
      bufferingView = UIActivityIndicatorView(frame: bounds)
      
//      bufferingView.center = center
      addSubview(bufferingView)
      NSLog("bufferingView frame: \(bufferingView.frame), center: \(bufferingView.center)")
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
