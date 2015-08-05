//
//  PlaylistViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/4/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController {
  var playlist: Playlist
  
  private var tracksViewController = TracksTableViewController()
  
  init(playlist: Playlist)
  {
    self.playlist = playlist
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - View Life Cycle
extension PlaylistViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    setupTracksList()
    addOptions()
  }
  
  private func setupTracksList()
  {
    tracksViewController.addToView(view, inViewController: self, withDelegate: self)
    tracksViewController.tracks = playlist.tracks
  }
  
  private func addOptions()
  {
    let optionsButton = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: "optionsTapped")
    navigationItem.rightBarButtonItem = optionsButton
  }
  
  func optionsTapped()
  {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "View Contributors", style: .Default) { (action) -> Void in
      self.viewContributors()
    })
    alert.addAction(UIAlertAction(title: "Add Contributors", style: .Default) { (action) -> Void in
      self.addContributors()
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
}

// MARK: - Tracks Table Delegate
extension PlaylistViewController: TracksTableViewControllerDelegate {
  func tracksTableControllerDidTriggerRefresh(streamTableController: TracksTableViewController)
  {
    
  }
  
  func tracksTableControllerDidScrollToEnd(streamTableController: TracksTableViewController)
  {
    
  }
}

// MARK: - Tracks Table Delegate
extension PlaylistViewController {
  private func viewContributors()
  {
    let viewContributorsVC = ViewContributorsViewController(playlist: playlist)
    navigationController!.pushViewController(viewContributorsVC, animated: true)
  }
  
  private func addContributors()
  {
    let addContributorsVC = AddContributorViewController(playlist: playlist)
    navigationController!.pushViewController(addContributorsVC, animated: true)
  }
}