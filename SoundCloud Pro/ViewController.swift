//
//  ViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 6/30/15.
//  Copyright (c) 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kTableViewOffset: CGFloat = 64

class ViewController: UIViewController {

  var streamList = StreamTableViewController()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    streamList.tableView.frame = UIView.rectWithinBars()
    view.addSubview(streamList.tableView)
  }

  override func viewDidAppear(animated: Bool)
  {
    super.viewDidAppear(animated)

    if SCSoundCloud.account() == nil {
      authorizeSoundCloud()
    } else {
      loadStream()
    }
  }
}

// MARK: - Helpers
extension ViewController {
  private func authorizeSoundCloud()
  {
    SCSoundCloud.requestAccessWithPreparedAuthorizationURLHandler { (url) -> Void in
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  private func loadStream()
  {
    let alert = SCLAlertView()
    alert.customViewColor = .orangeColor()
    alert.showWaiting(self, title: "Loading Stream", subTitle: nil, closeButtonTitle: nil, duration: 0)

    SoundCloud.getStream({ (tracks) -> Void in
      self.streamList.tracks = tracks
      alert.hideView()
    })
  }
}

