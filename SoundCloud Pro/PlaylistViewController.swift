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
  private var optionsButton: UIBarButtonItem!
  
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
    
    navigationItem.title = playlist.name
    setupTracksList()
    addOptions()
  }
  
  private func setupTracksList()
  {
    tracksViewController.swipeToDeleteEnabled = true
    tracksViewController.delegate = self
    tracksViewController.view.frame = view.bounds
    tracksViewController.addToView(view, inViewController: self, withDelegate: self)
    tracksViewController.tracks = playlist.tracks.filterDownVotes()
  }
  
  private func addOptions()
  {
    optionsButton = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: "optionsTapped")
    navigationItem.rightBarButtonItem = optionsButton
  }
  
  func optionsTapped()
  {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Add Track", style: .Default) { (action) -> Void in
      self.searchForTrack()
    })
    alert.addAction(UIAlertAction(title: "Delete Tracks", style: .Default) { (action) -> Void in
      self.beginEditing()
    })

    if playlist.type == .Shared {
      alert.addAction(UIAlertAction(title: "View Contributors", style: .Default) { (action) -> Void in
        self.viewContributors()
      })
      alert.addAction(UIAlertAction(title: "Add Contributors", style: .Default) { (action) -> Void in
        self.addContributors()
      })
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
}

// MARK: - Tracks Table Delegate
extension PlaylistViewController: TracksTableViewControllerDelegate {
  func tracksTableController(tracksTableController: TracksTableViewController, didDeleteTrack track: Track)
  {
    if playlist.name == kOnTheGoPlaylistName {
      UserPreferences.removeTrackFromOnTheGoPlaylist(track)
    }
    else {
      playlist.removeTrack(track) { () -> Void in
        self.tracksViewController.tracks = self.playlist.tracks
      }
    }
  }
}

// MARK: - Search Delegate
extension PlaylistViewController: SearchViewControllerDelegate {
  func searchViewController(searchViewController: SearchViewController, didSelectTrack track: Track)
  {
    playlist.addTrack(track) { () -> Void in
      self.tracksViewController.tracks = self.playlist.tracks
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func searchViewControllerDidTapCancel(searchViewController: SearchViewController)
  {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - Helpers
extension PlaylistViewController {
  private func searchForTrack()
  {
    let searchVC = SearchViewController.instance(delegate: self)
    presentViewController(searchVC, animated: true, completion: nil)
  }
  
  private func beginEditing()
  {
    tracksViewController.tableView.setEditing(true, animated: true)
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "endEditing")
  }
  
  func endEditing()
  {
    tracksViewController.tableView.setEditing(false, animated: true)
    navigationItem.rightBarButtonItem = optionsButton
  }
  
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