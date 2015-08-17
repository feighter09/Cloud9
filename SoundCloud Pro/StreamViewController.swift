//
//  StreamViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 6/30/15.
//  Copyright (c) 2015 Lost in Flight. All rights reserved.
//

import UIKit
import Parse

let kTableViewOffset: CGFloat = 64

class StreamViewController: LogoImageViewController {
  private lazy var tracksList: TracksTableViewController = {
    let tracks = TracksTableViewController()
    tracks.pullToRefreshEnabled = true
    tracks.infiniteScrollingEnabled = true
    return tracks
  }()
}

extension StreamViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    setupStreamList()
  }

  override func viewDidAppear(animated: Bool)
  {
    super.viewDidAppear(animated)

    if tracksList.tracks.count == 0 || !SoundCloud.userIsAuthenticated {
      loginAndLoadStream()
    }
    else {
      loadStreamWithAlert(false)
    }
  }
  
  private func setupStreamList()
  {
    tracksList.tableView.frame = UIView.rectWithinBars()
    tracksList.addToView(view, inViewController: self, withDelegate: self)
  }
}

// MARK: - Stream Table Delegate
extension StreamViewController: TracksTableViewControllerDelegate {
  func tracksTableControllerDidTriggerRefresh(streamTableController: TracksTableViewController)
  {
    loadStreamWithAlert(false)
  }
  
  func tracksTableControllerDidScrollToEnd(streamTableController: TracksTableViewController)
  {
    loadMoreStream()
  }
}

// MARK: - Helpers
extension StreamViewController {
  private func loginAndLoadStream()
  {
    if SCSoundCloud.account() == nil || PFUser.currentUser() == nil {
      SoundCloud.authenticateUser({ (success, error) -> Void in
        if success {
          self.loadStreamWithAlert(true)
        }
        else {
          ErrorHandler.handleNetworkingError("user credentials", error: error!)
        }
      })
    }
    else {
      loadStreamWithAlert(true)
    }
  }
  
  private func loadStreamWithAlert(showAlert: Bool)
  {
    // TODO: If it's still loading, going away and back to this VC makes 2 alerts show
    let alert: SCLAlertView? = (showAlert ? Utilities.showLoadingAlert("Buffering Stream", onViewController: self) : nil)

    SoundCloud.getStream({ (tracks, error) -> Void in
      alert?.hideView()
      
      if error == nil {
        self.tracksList.tracks = tracks
      }
      else {
        ErrorHandler.handleNetworkingError("stream", error: error)
      }
    })
  }
  
  private func loadMoreStream()
  {
    SoundCloud.getMoreStream { (tracks, error) -> Void in
      if error == nil {
        self.tracksList.tracks += tracks
      }
      else {
        ErrorHandler.handleNetworkingError("more stream tracks", error: error)
      }
    }
  }
}

