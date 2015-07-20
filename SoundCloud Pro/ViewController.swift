//
//  ViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 6/30/15.
//  Copyright (c) 2015 Lost in Flight. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  var streamList: StreamTableViewController!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    streamList = StreamTableViewController()
    view.addSubview(streamList.tableView)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if SCSoundCloud.account() == nil {
      SCSoundCloud.requestAccessWithPreparedAuthorizationURLHandler { (url) -> Void in
        UIApplication.sharedApplication().openURL(url)
      }
    } else {
      
      SoundCloud.getStream({ (tracks) -> Void in
        self.streamList.tracks = tracks
//        return
      })
    }
  }
}

