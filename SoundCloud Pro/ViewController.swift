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
  private var streamList = StreamTableViewController()
}

extension ViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    setupStreamList()
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
  
  private func setupStreamList()
  {
    streamList.tableView.frame = UIView.rectWithinBars()
    streamList.addToView(view, inViewController: self, withDelegate: self)
  }
}

// MARK: - Stream Table Delegate
extension ViewController: StreamTableViewControllerDelegate {
  func streamTableControllerDidScrollToEnd(streamTableController: StreamTableViewController)
  {
    loadMoreStream()
  }
}

// MARK: - Helpers
extension ViewController {
  private func authorizeSoundCloud()
  {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAuthenticate", name: kSoundCloudDidAuthenticate, object: nil)
    SCSoundCloud.requestAccessWithPreparedAuthorizationURLHandler { (url) -> Void in
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  private func loadStream()
  {
    let alert = SCLAlertView()
    alert.customViewColor = .orangeColor()
    alert.showWaiting(self, title: "Loading Stream", subTitle: nil, closeButtonTitle: nil, duration: 0)

    SoundCloud.getStream({ (tracks, error) -> Void in      
      alert.hideView()
      
      if error == nil {
        self.streamList.tracks = tracks
      } else {
        ErrorHandler.handleNetworkingError("stream", error: error)
      }
    })
  }
  
  private func loadMoreStream()
  {
    SoundCloud.getMoreStream { (tracks, error) -> Void in
      if error == nil {
        self.streamList.tracks += tracks
      } else {
        ErrorHandler.handleNetworkingError("more stream tracks", error: error)
      }
    }
  }
  
  func didAuthenticate()
  {
    loadStream()
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

