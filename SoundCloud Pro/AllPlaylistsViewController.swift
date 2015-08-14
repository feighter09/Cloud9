//
//  AllPlaylistsViewController.swift
//  SoundCloud Pro
//
//  Created by Austin Feight on 7/29/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

import UIKit

let kLoadingCellIdentifier = "loadingCell"
let kNoPlaylistsCellIdentifier = "noPlaylists"

let kLocalPlaylistSection = 0
let kSharedPlaylistSection = 1
let kMyPlaylistSection = 2

class AllPlaylistsViewController: UIViewController {
  var sharedPlaylists: [Playlist]! {
    didSet { tableView.reloadData() }
  }
  
  var myPlaylists: [Playlist]! {
    didSet { tableView.reloadData() }
  }

  @IBOutlet private weak var tableView: UITableView!
}

// MARK: - View Life Cycle
extension AllPlaylistsViewController {
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    setupTable()
    loadPlaylists()
  }
  
  func loadPlaylists()
  {
    myPlaylists = nil
    sharedPlaylists = nil
    
    loadSharedPlaylists()
    loadMyPlaylists()
  }

  private func setupTable()
  {
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  private func loadMyPlaylists()
  {
    SoundCloud.getMyPlaylists { (playlists, error) -> Void in
      if error == nil {
        self.myPlaylists = playlists
      }
      else {
        ErrorHandler.handleNetworkingError("my playlists", error: error)
      }
    }
  }
  
  private func loadSharedPlaylists()
  {
    SoundCloud.getSharedPlaylists { (playlists, error) -> Void in
      if error == nil {
        self.sharedPlaylists = playlists
      }
      else {
        ErrorHandler.handleNetworkingError("shared playlists", error: error)
      }
    }
  }
}

// MARK: - Table View Data Source
extension AllPlaylistsViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int
  {
    return 3
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  {
    switch section {
      case kSharedPlaylistSection: return "Shared Playlists"
      case kMyPlaylistSection: return "My Playlists"
      default: return nil
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    if !rowsLoadedForSection(section) || playlistForSectionIsEmpty(section) { return 1 }
    
    return playlistsForSection(section).count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    var cell: UITableViewCell
    
    if !rowsLoadedForSection(indexPath.section) {
      let loadingCell = tableView.dequeueReusableCellWithIdentifier(kLoadingCellIdentifier, forIndexPath: indexPath) as! LoadingCell
      loadingCell.animate()
      cell = loadingCell
    }
    else if playlistForSectionIsEmpty(indexPath.section) {
      let normalCell = tableView.dequeueReusableCellWithIdentifier(kNoPlaylistsCellIdentifier, forIndexPath: indexPath)
      normalCell.textLabel?.text = "No playlists!"
      cell = normalCell
    }
    else {
      let playlistCell = tableView.dequeueReusableCellWithIdentifier(kPlaylistCellIdentifier, forIndexPath: indexPath) as! PlaylistCell
      playlistCell.playlist = playlistForIndexPath(indexPath)
      cell = playlistCell
    }
    
    cell.backgroundColor = .backgroundColor
    cell.tintColor = .detailColor
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
  {
    let headerView = view as! UITableViewHeaderFooterView
    headerView.contentView.backgroundColor = .backgroundColor
    headerView.textLabel?.textColor = .detailColor
  }
  
  private func rowsLoadedForSection(section: Int) -> Bool
  {
    return playlistsForSection(section) != nil
  }
}

// MARK: - UI Actions
extension AllPlaylistsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let playlist = playlistForIndexPath(indexPath) {
      presentPlaylist(playlist)
    }
  }
  
  @IBAction func addPlaylistTapped(sender: AnyObject)
  {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "New Shared Playlist", style: .Default, handler: { (action) -> Void in
      self.showAddPlaylistAlert(.Shared)
    }))
//    alert.addAction(UIAlertAction(title: "New Playlist", style: .Default, handler: { (action) -> Void in
//      self.showAddPlaylistAlert(.Normal)
//    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func refreshTapped(sender: AnyObject)
  {
    loadPlaylists()
  }
  
  private func presentPlaylist(playlist: Playlist)
  {
    let playlistVC = PlaylistViewController(playlist: playlist)
    navigationController?.pushViewController(playlistVC, animated: true)
  }
}

// MARK: - Helpers
extension AllPlaylistsViewController {
  private func playlistsForSection(section: Int) -> [Playlist]!
  {
    switch section {
      case kLocalPlaylistSection: return [UserPreferences.onTheGoPlaylist, UserPreferences.recentsPlaylist]
      case kSharedPlaylistSection: return sharedPlaylists
      case kMyPlaylistSection: return myPlaylists
      default: fatalError()
    }
  }
  
  private func playlistForIndexPath(indexPath: NSIndexPath) -> Playlist!
  {
    let playlist = playlistsForSection(indexPath.section)
    return playlist.count > 0 ? playlist[indexPath.row] : nil
  }
  
  private func playlistForSectionIsEmpty(section: Int) -> Bool
  {
    return playlistsForSection(section).count == 0
  }

  private func showAddPlaylistAlert(playlistType: PlaylistType)
  {
    let alert = UIAlertController(title: "New \(playlistType.rawValue) Playlist", message: nil, preferredStyle: .Alert)
    alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
      textField.placeholder = "name"
    }
    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { [unowned alert] (action) -> Void in
      let name = alert.textFields!.first!.text!
      SoundCloud.createPlaylistWithName(name, type: playlistType, callback: self.createPlaylistHandler)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func createPlaylistHandler(success: Bool, error: NSError?)
  {
    if error == nil {
      loadPlaylists()
    }
    else {
      ErrorHandler.handleNetworkingError("creating playlists", error: error!)
    }
  }
}
